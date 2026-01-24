<?php
// Load Composer autoloader.
require_once dirname( dirname( __FILE__ ) ) . '/vendor/autoload.php';

// Load the PHPUnit Polyfills for the WP testing suite.
define( 'WP_TESTS_PHPUNIT_POLYFILLS_PATH', 
        dirname( dirname( __FILE__ ) ) . '/vendor/yoast/phpunit-polyfills' );

