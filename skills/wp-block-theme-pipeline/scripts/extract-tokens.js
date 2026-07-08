// Design token extractor — run via: agent-browser eval "$(cat extract-tokens.js)"
// Walks visible elements, collects computed styles, and returns a JSON summary.
// Output is a DRAFT: hover/focus states are not captured and third-party
// widgets add noise; normalization happens in Stage 2 of the pipeline.
(() => {
	const counts = (map, key) => map.set(key, (map.get(key) || 0) + 1);
	const colors = new Map();
	const colorRoles = {}; // color -> { text: n, bg: n, border: n }
	const fontSizes = new Map();
	const fontFamilies = new Map();
	const fontWeights = new Map();
	const lineHeights = new Map();
	const spacings = new Map();
	const radii = new Map();
	const shadows = new Map();
	const containerWidths = new Map();

	const addRole = (color, role) => {
		if (!color || color === 'rgba(0, 0, 0, 0)' || color === 'transparent') return;
		counts(colors, color);
		colorRoles[color] = colorRoles[color] || { text: 0, bg: 0, border: 0 };
		colorRoles[color][role] += 1;
	};

	const isVisible = (el) => {
		const r = el.getBoundingClientRect();
		return r.width > 0 && r.height > 0;
	};

	const els = document.querySelectorAll('body *');
	const limit = Math.min(els.length, 5000);
	for (let i = 0; i < limit; i++) {
		const el = els[i];
		if (!isVisible(el)) continue;
		const s = getComputedStyle(el);

		addRole(s.color, 'text');
		addRole(s.backgroundColor, 'bg');
		if (s.borderTopWidth !== '0px') addRole(s.borderTopColor, 'border');

		if (el.textContent && el.textContent.trim()) {
			counts(fontSizes, s.fontSize);
			counts(fontFamilies, s.fontFamily);
			counts(fontWeights, s.fontWeight);
			counts(lineHeights, s.lineHeight);
		}

		['paddingTop', 'paddingBottom', 'marginTop', 'marginBottom', 'gap'].forEach((p) => {
			const v = s[p];
			if (v && v !== '0px' && v !== 'normal' && !v.includes('%')) counts(spacings, v);
		});

		if (s.borderRadius && s.borderRadius !== '0px') counts(radii, s.borderRadius);
		if (s.boxShadow && s.boxShadow !== 'none') counts(shadows, s.boxShadow);

		// Candidate content containers: centered elements with a max-width.
		if (s.maxWidth && s.maxWidth !== 'none' && s.marginLeft === s.marginRight) {
			counts(containerWidths, s.maxWidth);
		}
	}

	const top = (map, n) =>
		[...map.entries()].sort((a, b) => b[1] - a[1]).slice(0, n)
			.map(([value, count]) => ({ value, count }));

	return JSON.stringify({
		url: location.href,
		title: document.title,
		colors: top(colors, 40).map((c) => ({ ...c, roles: colorRoles[c.value] })),
		fontSizes: top(fontSizes, 15),
		fontFamilies: top(fontFamilies, 5),
		fontWeights: top(fontWeights, 8),
		lineHeights: top(lineHeights, 8),
		spacings: top(spacings, 25),
		radii: top(radii, 8),
		shadows: top(shadows, 8),
		containerWidths: top(containerWidths, 8),
	}, null, 2);
})();
