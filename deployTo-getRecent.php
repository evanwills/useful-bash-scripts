<?php

/**
 * This file is to be used by deployTo.sh to return a list of
 * recently updated files that should be uploaded to a server.
 *
 * It is assumed that this script will be called by the shell script
 * deployTo.sh
 *
 * It expects two parameters:
 * 1. (srcList)   A space separated list of relative paths for files
 *                and directories that are eligible to be uploaded.
 * 2. (sinceTime) An integer representing the unix timestamp used to
 *                compare the modification time of each eligible.
 *                If the modification time is greater than the
 *                sinceTime they are included in the list
 *
 * The this script echos out a string representing a two dimensional
 * array. The first level is the destination path. The second level
 * is each eligible file for that path.
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
if ($_SERVER['argc'] < 3) {
    trigger_error(
        __FILE__." expects at least two parameters to be passed: \n".
        "   srcList - a space separated list of eligible paths\n".
        "and\n".
        "   sinceTime - a unix timestame after which modified ".
        "files are eligible for upload",
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

if (!is_numeric($_SERVER['argv'][2]) || $_SERVER['argv'][2] < time() - 31557600) {
    trigger_error(
        __FILE__." expects first parameter srcList to be a non \n".
        "empty string",
        E_USER_WARNING
    );
    $ok = false;
} else {
    $sinceTime = $_SERVER['argv'][2] * 1;
}

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
        }
        $output .= $sep1."$srcList [[HOST]]$key;";
        $sep1 = "\n";
    }
}
// debug($output);
// echo "\n\n\n$output\n\n\n";
if ($output !== '') {
    $fileName = 'deployList__'.date('Y-m-d-H-i-s').'.txt';
    file_put_contents($fileName, $output);
    echo $fileName;
} else {
    echo '';
}
