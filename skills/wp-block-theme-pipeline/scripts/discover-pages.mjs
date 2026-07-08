// Page discovery for /make-block Stage 1.
// Fetches the site's sitemap, classifies URLs by page type, clusters
// same-template URLs, and outputs ONE representative URL per cluster —
// so extraction never scans two pages that share a layout.
//
// Usage:
//   node discover-pages.mjs <site-url> [--max-per-cluster=1] [--json]
//
// Output: JSON report { clusters: [{ pattern, type, count, sample, urls }] }.

const args = process.argv.slice(2);
const siteArg = args.find((a) => !a.startsWith("--"));
if (!siteArg) {
	console.error("Usage: node discover-pages.mjs <site-url>");
	process.exit(1);
}
const origin = new URL(siteArg).origin;

async function fetchText(url) {
	try {
		const res = await fetch(url, { redirect: "follow", headers: { "user-agent": "make-block-discovery" } });
		if (!res.ok) return null;
		return await res.text();
	} catch {
		return null;
	}
}

function extractLocs(xml) {
	return [...xml.matchAll(/<loc>\s*([^<\s]+)\s*<\/loc>/g)].map((m) => m[1]);
}

// Collect page URLs from sitemap indexes and urlsets, recursively.
async function collectUrls() {
	const candidates = [
		`${origin}/sitemap.xml`,
		`${origin}/sitemap_index.xml`,
		`${origin}/wp-sitemap.xml`,
	];

	// robots.txt may declare a non-standard sitemap location.
	const robots = await fetchText(`${origin}/robots.txt`);
	if (robots) {
		for (const m of robots.matchAll(/^sitemap:\s*(\S+)/gim)) candidates.unshift(m[1]);
	}

	const pageUrls = new Set();
	const seenSitemaps = new Set();
	const queue = [...new Set(candidates)];

	while (queue.length > 0 && seenSitemaps.size < 50) {
		const smUrl = queue.shift();
		if (seenSitemaps.has(smUrl)) continue;
		seenSitemaps.add(smUrl);

		const xml = await fetchText(smUrl);
		if (!xml) continue;

		for (const loc of extractLocs(xml)) {
			if (/\.xml(\?|$)/.test(loc)) queue.push(loc);
			else if (loc.startsWith(origin) && !/\.(jpg|jpeg|png|gif|webp|svg|pdf|mp4)(\?|$)/i.test(loc)) {
				pageUrls.add(loc.split("#")[0]);
			}
		}
		if (pageUrls.size > 2000) break;
	}

	return [...pageUrls];
}

// Normalize a URL path into a template pattern: numeric segments -> {n},
// date segments -> {date}, deep slugs -> {slug}. Same pattern = same template.
function toPattern(url) {
	const path = new URL(url).pathname.replace(/\/+$/, "") || "/";
	const segs = path.split("/").filter(Boolean);
	const norm = segs.map((s, i) => {
		if (/^\d{4}$/.test(s) || /^\d{1,2}$/.test(s)) return "{n}";
		if (/^page$/i.test(s)) return "page";
		// The LAST segment of a deep path is usually the item slug.
		if (i === segs.length - 1 && segs.length >= 2) return "{slug}";
		return s;
	});
	return "/" + norm.join("/");
}

// Heuristic page-type classification from the pattern shape.
function classify(pattern, count) {
	if (pattern === "/") return "home";
	if (/\{slug\}$/.test(pattern) && count >= 3) {
		// Many URLs sharing a prefix + trailing slug = single (post/product/…).
		return "single";
	}
	if (/(category|tag|taxonomy|archive|blog|news|products|shop)\/?$/i.test(pattern)) return "archive";
	if (/\{n\}/.test(pattern)) return "archive";
	if (count >= 5) return "single";
	return "page"; // Low-count distinct paths are static pages.
}

const urls = await collectUrls();

if (urls.length === 0) {
	console.error(`No sitemap found at ${origin} — fall back to crawling nav links from the homepage.`);
	process.exit(2);
}

const clusters = new Map();
for (const url of urls) {
	const pattern = toPattern(url);
	if (!clusters.has(pattern)) clusters.set(pattern, []);
	clusters.get(pattern).push(url);
}

const report = {
	origin,
	totalUrls: urls.length,
	clusters: [...clusters.entries()]
		.map(([pattern, list]) => ({
			pattern,
			type: classify(pattern, list.length),
			count: list.length,
			sample: list[0],
		}))
		.sort((a, b) => b.count - a.count),
};

// Suggested scan list: home + every static page + one sample per archive/single cluster.
report.scanList = report.clusters
	.filter((c) => c.type === "home" || c.type === "page")
	.map((c) => ({ url: c.sample, type: c.type }))
	.concat(
		report.clusters
			.filter((c) => c.type === "archive" || c.type === "single")
			.map((c) => ({ url: c.sample, type: c.type }))
	);

process.stdout.write(JSON.stringify(report, null, 2) + "\n");
