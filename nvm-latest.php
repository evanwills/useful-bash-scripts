<?php

/**
 * This file works out whether nvm has the latest current & LTS versions.
 * If not it returns the version numbers to install
 *
 * PHP version 7.4
 *
 * @category Scripts
 * @package  Scripts
 * @author   Evan Wills <evan.wills@acu.edu.au>
 * @license  MIT https://opensource.org/licenses/MIT
 * @link     https://github.com/evanwills/useful-bash-scripts
 */

// ===================================================================
// START: Boot-strapping


$debugPath =  realpath(__DIR__.'/../includes/debug.inc.php');

if ($debugPath !== false && is_file($debugPath)) {
    include_once $debugPath;
} else {
    /**
     * Dummy debug function
     *
     * @return void
     */
    function debug()
    {

    }
}

//  END:  Boot-strapping
// ===================================================================

define(
    'REGEX',
    '/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(?: \(Currently.*)?$/i'
);

// Even major versions are LTS
$releaseType = ($_SERVER['argv'][2] === 'lts')
    ? 2
    : 1;

// debug($_SERVER['argv'][1], $_SERVER['argv'][2]);

$tmp = explode(' ', $_SERVER['argv'][1]);

for ($a = 0, $c = count($tmp); $a < $c; $a += 1) {
    $tmp[$a] = trim($tmp[$a]);

    if ($tmp[$a] !== '' && preg_match(REGEX, $tmp[$a], $matches)) {
        // Split the version number into Major, Minor & Patch
        $v = explode('.', $matches[1]);

        // Check whether the major version number
        // matches the type we want
        if (is_int($v[0] / $releaseType)) {
            echo $matches[1];
            exit;
        }
    }
}

echo '';
