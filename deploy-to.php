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


//  END:  Boot-strapping
// ===================================================================
// START: Initial setup & validation

/**
 * Name of the config data source for this script
 *
 * @var string
 */
$jsonFile = 'deploy-to.json';

/**
 * Absolute file path to the config data source for this script
 *
 * @var string
 */
$json = PWD.$jsonFile;

if (!is_file($json)) {
    trigger_error(
        __FILE__." expects to be called from a directory that ".
        "contains a $jsonFile file, used to define what is ".
        "to be deployed & where it should be deployed to\n".
        PWD." does not cotain a file named \"$jsonFile\"\n",
        E_USER_ERROR
    );
} else {
    try {
        $data = json_decode(file_get_contents($json));
    } catch (Exception $e) {
        trigger_error(
            $json.' contained invalid JSON: '.$e->getMessage(),
            E_USER_ERROR
        );
    }

    if (!is_array($data->servers) || count($data->servers) === 0) {
        trigger_error(
            $json.' does not contain any server details',
            E_USER_ERROR
        );
    }

    if (!is_array($data->sourceList) || count($data->sourceList) === 0) {
        trigger_error(
            $json.' does not contain any files to deploy',
            E_USER_ERROR
        );
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
        "environment name - \"name\" property of one of the servers listed\n".
        "                   in the \"servers\" list in the deploy-to.json \n".
        "and\n".
        "       file name - The name of the output script file if items are\n".
        "                   found to deploy\n\n".
        "files are eligible for upload",
        E_USER_ERROR
    );
}

/**
 * Whether or not it's OK to proceed with executing the rest
 * of this script
 *
 * @var boolean
 */
$ok = false;

/**
 * Object containing basic information about the server selected
 * to deploy to
 *
 * @var object|false (FALSE if no target server was found)
 */
$server = false;

$_SERVER['argv'][1] = trim($_SERVER['argv'][1]);
if ($_SERVER['argv'][1] === '') {
    trigger_error(
        __FILE__." expects first parameter srcList to be a non \n".
        'empty string',
        E_USER_WARNING
    );
} else {
    for ($a = 0; $a < count($data->servers); $a += 1) {
        /**
         * Details about one of the deployment targets for the
         * current context
         *
         * @var object
         */
        $tmp = $data->servers[$a];
        if (!is_object($tmp)) {
            trigger_error(
                'Every item in the Servers list must be an object. Item '.
                ($a + 1).' is '.gettype(),
                E_USER_WARNING
            );
        }

        if (!property_exists($tmp, 'name')
            || !property_exists($tmp, 'host')
            || !property_exists($tmp, 'user')
            || !property_exists($tmp, 'path')
        ) {
            trigger_error(
                'Every item Servers must be an object '.
                'containing the following properties: '.
                '"name", "host", "user", "path"'.
                ($a + 1).' is '.gettype($tmp),
                E_USER_WARNING
            );
        }

        if ($tmp->name === $_SERVER['argv'][1]) {
            $server = $tmp;
            $ok = true;
            break;
        }
    }
}

if ($server === false) {
    trigger_error(
        'Could not find any information about the server we should '.
        'push to',
        E_USER_WARNING
    );
}

/**
 * Regular expression to ensure that file name matches expected
 * output file name
 *
 * @var string
 */
$regex = '/^deployList__20(?:\d{2}-){3}(?:-\d{2}){3}\.sh$/i';

$_SERVER['argv'][2] = trim($_SERVER['argv'][2]);
if (is_string($_SERVER['argv'][2])
    && preg_match($regex, $_SERVER['argv'][2])
) {
    /**
     * Absolute path to where the bash script generated by this
     * PHP script will be stored.
     *
     * @var string
     */
    $fileName = PWD.$_SERVER['argv'][2];
    $ok = true;
} else {
    trigger_error(
        __FILE__." expects the second argument to be a string \n".
        "for the file name for the shell script to\n".
        "do the actual work of uploading files.",
        E_USER_WARNING
    );
}

if ($ok === false) {
    echo "\n\nEnding now due to insufficient or unreliable supplied data\n\n";
    exit;
}

/**
 * Absolute path to where the time check file for the last
 * deployment is stored.
 *
 * @var string
 */
$timeCheckFile = PWD.'.lastDeployment-'.$server->name;

if (array_key_exists(3, $_SERVER['argv']) && $_SERVER['argv'][3] === 'force') {
    /**
     * Unix timestamp for when the last deployment to the chosen
     * environment was run
     *
     * @var integer
     */
    $sinceTime = 0;
} else {
    if (is_file($timeCheckFile)) {
        $sinceTime = filemtime($timeCheckFile);
    } else {
        $sinceTime = 0;
    }
}

/**
 * SCP Username, host and root path for application files are
 * being uploaded to
 *
 * @var string
 */
$host = $server->user.'@'.$server->host.':'.$server->path;


/**
 * Date/time string to use for reporting when deployment was
 * last run
 *
 * @var string
 */
define('FANCY_DATE', 'H:i:s \o\n l, \t\h\e jS \o\f F Y');

//  END:  Initial setup & validation
// ===================================================================
// START: Function declarations

/**
 * Convert a windows file system path string to a unix file
 * system path string
 *
 * @param string $path Path to be converted
 *
 * @return string
 */
function unixPath(string $path) : string
{
    return str_replace(
        array(' ', 'C:', '\\'),
        array('\\ ', '/c', '/'),
        trim($path)
    );
}

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

/**
 * Populate template bash script with values generated by this
 * PHP script
 *
 * @param array $data Associative array containing key/value pairs
 *                    used to populate template bash script
 *
 * @return string
 */
function populateScript(array $data) : string
{
    $_tmpl = __DIR__.DIRECTORY_SEPARATOR.'deploy-to.tmpl.sh';
    $tmpl = realpath($_tmpl);

    if (!is_file($tmpl)) {
        trigger_error(
            'Could not find bash script template file at "'.$_tmpl.'"',
            E_USER_ERROR
        );
    }

    $find = array();
    $replace = array();

    foreach ($data as $key => $value) {
        $find[] = '[['.strtoupper($key).']]';
        $replace[] = $value;
    }

    return str_replace($find, $replace, file_get_contents($tmpl));
}


//  END:  Initial setup & validation
// ===================================================================
// START: Function declarations


/**
 * List of all files to be uploaded (not grouped)
 *
 * @var array
 */
$tmp = array();
// Get all eligible files for each path
for ($a = 0; $a < count($data->sourceList); $a += 1) {
    $tmp = array_merge(
        $tmp,
        getDeployable(PWD.$data->sourceList[$a], $sinceTime)
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

/**
 * List of all the SCP calls to deploy all the appropriate files
 * to the deployment target
 *
 * @var string
 */
$output = '';

/**
 * Count of all individual SCP calls to fulfill deployment
 *
 * @var integer
 */
$groupC = 0;

/**
 * Count of total number of files to be deployed
 */
$fileC = 0;

// Build a splittable string for use by the calling script
foreach ($grouped as $path => $source) {
    if (count($source) > 0) {
        /**
         * List of all files being deployed to a specific
         * location on the destination server
         *
         * @var string
         */
        $srcList = '';

        for ($a = 0; $a < count($source); $a += 1) {
            $srcList .= ' '.unixPath($source[$a]);
            $fileC += 1;
        }

        $output .= "\nscp$srcList {$host}$path;";
        $groupC += 1;
    }
}

if ($output !== '') {
    $parts = array(
        'host' => $server->host,
        'server_name' => $server->name,
        'created' => date('Y-m-d H:i:s'),
        'user' => $_SERVER['USERNAME'],
        'time_check_file' => unixPath($timeCheckFile),
        'file_C' => $fileC,
        'file_S' =>  ($fileC > 1) ? 's' : '',
        'group_C' => $groupC,
        'group_S' =>  ($groupC > 1) ? 's' : '',
        'since' => ($sinceTime > 0)
            ? "'that have been updated since';\necho\t'".
                date(FANCY_DATE, $sinceTime)."';"
            : "'\t(Full deployment)';",
        'output' => $output
    );

    file_put_contents($fileName, populateScript($parts));
}
