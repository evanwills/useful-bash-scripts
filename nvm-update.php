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

define('PWD', realpath($_SERVER['PWD']).DIRECTORY_SEPARATOR);


//  END:  Boot-strapping
// ===================================================================

define(
    'REGEX',
    '/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(?: \(Currently.*)?$/i'
);

// debug($_SERVER['argv'][1], $_SERVER['argv'][2]);

$toInstall = [];
$installed = [];

$tmp = explode(' ', $_SERVER['argv'][1]);

for ($a = 0, $c = count($tmp); $a < $c; $a += 1) {
    $tmp[$a] = trim($tmp[$a]);
    if ($tmp[$a] !== '' && preg_match(REGEX, $tmp[$a], $matches)) {
        $installed[] = $matches[1];
    }
}

$tmp = explode('|', $_SERVER['argv'][2]);

for ($a = 0, $b = 0, $c = count($tmp); $a < $c; $a += 1) {
    $tmp[$a] = trim($tmp[$a]);
    if ($tmp[$a] !== '' && preg_match(REGEX, $tmp[$a], $matches)) {
        $b += 1;

        if (!in_array($matches[1], $installed)) {
            $toInstall[] = $matches[1];
        }

        if ($b >= 2) {
            break;
        }
    }
}

// debug($installed, $toInstall);

echo implode(';', $toInstall);
// echo '17.2.0;16.13.0';
