<?php

/**
 * This file is to be used by deployTo.sh to create a shell script
 * with a custom list of files to be uploaded
 *
 * It is assumed that this script will be called by the shell script
 * deployTo.sh
 *
 * It expects three parameters:
 * 1. (srcList)   A space separated list of relative paths for files
 *                and directories that are eligible to be uploaded.
 * 2. (sinceTime) An integer representing the unix timestamp used to
 *                compare the modification time of each eligible.
 *                If the modification time is greater than the
 *                sinceTime they are included in the list
 * 3. (host)      ssh username, host & path to application root used
 *                to prefix the destination part of an SCP command
 *                e.g. username@subdomain.host.com:/path/to/app/root
 *
 * The this script echos out a the file name of the custom shell
 * script it has just generated so the calling script can execute it
 *
 * PHP version 7.4
 *
 * @category Qist
 * @package  Qist
 * @author   Evan Wills <evan.wills@acu.edu.au>
 * @license  MIT https://opensource.org/licenses/MIT
 * @link     https://gitlab.acu.edu.au/evwills/acu-payment-forms
 */

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

if (!array_key_exists('argv', $_SERVER)) {
    trigger_error(
        __FILE__.' must be called via called via the commandline '.
        'and have a Server "argv" value',
        E_USER_ERROR
    );
}
if ($_SERVER['argc'] < 4) {
    trigger_error(
        __FILE__." expects at least three parameters to be passed: \n".
        "   srcList   - a space separated list of eligible paths\n".
        "and\n".
        "   sinceTime - a unix timestame after which modified files\n".
        "               are eligible for upload\n".
        "and\n".
        "   host      - username, host and path to be used in SCP call\n".
        "               e.g. josmith@example.com:/var/www/html/",
        E_USER_ERROR
    );
}

$ok = true;
$_SERVER['argv'][1] = trim($_SERVER['argv'][1]);
if ($_SERVER['argv'][1] === '') {
    trigger_error(
        __FILE__." expects first parameter srcList to be a non \n".
        "empty string",
        E_USER_WARNING
    );
    $ok = false;
}

if (!is_numeric($_SERVER['argv'][2])
    || ($_SERVER['argv'][2] > 0 && $_SERVER['argv'][2] < (time() - 31557600))
) {
    trigger_error(
        __FILE__." expects second parameter sinceTime to be a non \n".
        "empty string",
        E_USER_WARNING
    );
    $ok = false;
} else {
    $sinceTime = $_SERVER['argv'][2] * 1;
}

$host = $_SERVER['argv'][3];

if ($ok === false) {
    echo "\n\nEnding now due to insufficient or unreliable supplied data\n\n";
    exit;
}

// debug('server');

$srcList = explode(' ', $_SERVER['argv'][1]);
define(
    'PWD',
    realpath(
        str_replace(
            array('/c', '/'),
            array('C:', '\\'),
            $_SERVER['PWD']
        )
    ).DIRECTORY_SEPARATOR
);

/**
 * Make the path minTTY compliant
 *
 * @param string $path Path to be cleaned up
 *
 * @return string
 */
function clean(string $path) : string
{
    return preg_replace_callback(
        '/^([a-z]):(?=\/)/i',
        function ($matches) {
            return '/'.strtolower($matches[1]);
        },
        $path
    );
}

/**
 * Get a list of files that have been updated since $last
 *
 * @param string  $path Path to directory or file
 * @param integer $last Unix timestamp after which updated files
 *                      should be included
 *
 * @return array
 */
function getDeployable(string $path, int $last) : array
{
    $real = realpath($path);
    $output = array();
    // debug($path, $last, $real);

    if (is_file($real)) {
        if (filemtime($real) > $last) {
            $output[] = array(
                'local' => clean(trim($path)),
                'remote' => trim(
                    preg_replace(
                        '`^(.*?/)?[^/]*$`',
                        '\1',
                        str_replace(PWD, '', $path)
                    )
                )
            );
        }
    } elseif (is_dir($real)) {
        $children = scandir($real);
        // debug($path, $real, $children);
        for ($a = 0; $a < count($children); $a += 1) {
            // debug($path.$children[$a]);
            if ($children[$a] !== '..' && $children[$a] !== '.') {
                $output = array_merge(
                    $output,
                    getDeployable("$path/{$children[$a]}", $last)
                );
            }
        }
    }
    return $output;
}

//
$tmp = array();
// Get all eligible files for each path
for ($a = 0; $a < count($srcList); $a += 1) {
    $tmp = array_merge(
        $tmp,
        getDeployable(PWD.$srcList[$a], $sinceTime)
    );
}
// debug($tmp);

$grouped = array();

// Group files by their destination path (speeds up SCP calls)
for ($a = 0; $a < count($tmp); $a += 1) {
    $key = trim($tmp[$a]['remote']);
    $value = $tmp[$a]['local'];
    if (!array_key_exists($key, $grouped)) {
        $grouped[$key] = array($value);
    } else {
        $grouped[$key][] = $value;
    }
}

$output = '';
$sep1 = '';
$groupC = 0;
$fileC = 0;

// Build a splittable string for use by the calling script
foreach ($grouped as $key => $value) {
    if (count($value) > 0) {
        $srcList = '';
        $sep2 = '';
        for ($a = 0; $a < count($value); $a += 1) {
            $srcList .= $sep2.str_replace(
                array(' ','C:', '\\'),
                array('\\ ', '/c', '/'),
                trim($value[$a])
            );
            $sep2 = ' ';
            $fileC += 1;
        }
        $output .= "$sep1 scp $srcList {$host}$key;";
        $sep1 = "\n";
        $groupC += 1;
    }
}

$fileS = ($fileC > 1) ? 's' : '';
$groupS = ($groupC > 1) ? 's' : '';
$since = date('H:i:s D, \t\h\e jS \o\f M Y');

/**
 * Custom shell script content
 *
 * @var string
 */
$shell = '#!/bin/sh

echo;
echo;
echo \'About to upload '.$fileC.' file'.$fileS.' in '.$groupC.' group'.$groupS.'\';
echo \'that have been updated since '.$since.'\';
echo;
echo;
[[OUTPUT]]
echo;
echo;
';

// debug($output);
// echo "\n\n\n$output\n\n\n";
if ($output !== '') {
    $fileName = 'deployList__'.date('Y-m-d-H-i-s').'.sh';
    file_put_contents(
        $fileName,
        str_replace('[[OUTPUT]]', $output, $shell)
    );
    echo $fileName;
} else {
    echo '';
}
