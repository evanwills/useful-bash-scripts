<?php

/**
 * This file is to be used by deploy-to.sh to create a bash script
 * with a custom list of files to be uploaded
 *
 * It is assumed that this script will be called by the shell script
 * deploy-to.sh
 *
 * It expects two or three parameters:
 * 1. (environment) A string that matches one of the "name"s of
 *                  servers listed in deploy-to.json in the current
 *                  working directory
 * 2. (scriptName)  The name of the file the output of this script
 *                  will be written to
 * 3. (force)       [optional] Whether or not to force deploying all
 *                  files regardless of when they were updated
 *
 * It depends on the presence of deploy-to.json in the current
 * working directory to provide the necessary config to be able to
 * select which files are to be deployed to the appropriate server.
 * (see deploy-to.json in this directory for template)
 *
 * PHP version 7.4
 *
 * @category Qist
 * @package  Qist
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

    if (!property_exists($data, 'default')
        || !is_string($data->default)
        || trim($data->default) === ''
    ) {
        trigger_error(
            $json.' does not contain the name of a default server',
            E_USER_ERROR
        );
    }

    if (!property_exists($data, 'servers')
        || !is_array($data->servers)
        || count($data->servers) === 0
    ) {
        trigger_error(
            $json.' does not contain any server details',
            E_USER_ERROR
        );
    }

    if (!property_exists($data, 'sourceList')
        || !is_array($data->sourceList)
        || count($data->sourceList) === 0
    ) {
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
if ($_SERVER['argc'] < 2) {
    trigger_error(
        __FILE__." expects at least one parameter to be passed: \n".
        "       file name - The name of the output script file if items are\n".
        "                   found to deploy\n\n".
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


/**
 * Object containing basic information about the default server
 * to deploy to
 *
 * @var object|false (FALSE if no default server was found)
 */
$defaultServer = false;

$tmpEnv = (array_key_exists(2, $_SERVER['argv']) && trim($_SERVER['argv'][2]) !== '')
    ? trim($_SERVER['argv'][2])
    : '[[DEFAULT]]'; // "[[default]]" should not match any server name
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
            ($a + 1).' is '.gettype($tmp),
            E_USER_ERROR
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
            E_USER_ERROR
        );
    }

    if ($tmp->name === $tmpEnv) {
        $server = $tmp;
        $ok = true;
        break;
    } elseif ($tmp->name === $data->default && $server === false) {
        // We'll set the default server as the selected server
        // but keep checking in case we can match a specific server
        $server = $tmp;
    }
}

if ($server === false) {
    trigger_error(
        'Could not find any information about the server we should '.
        'push to',
        E_USER_ERROR
    );
}

/**
 * Regular expression to ensure that file name matches expected
 * output file name
 *
 * @var string
 */
$regex = '/^deployList__20(?:\d{2}-){3}(?:-\d{2}){3}\.sh$/i';

$_SERVER['argv'][1] = trim($_SERVER['argv'][1]);
if (is_string($_SERVER['argv'][1])
    && preg_match($regex, $_SERVER['argv'][1])
) {
    /**
     * Absolute path to where the bash script generated by this
     * PHP script will be stored.
     *
     * @var string
     */
    $fileName = PWD.$_SERVER['argv'][1];
    $ok = true;
} else {
    trigger_error(
        __FILE__." expects the second argument to be a string \n".
        "for the file name for the shell script to\n".
        "do the actual work of uploading files.",
        E_USER_ERROR
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
 * Basic SCP user/host identifier
 *
 * @var string
 */
define('HOST', $server->user.'@'.$server->host.':');

/**
 * SCP Username, host and root path for application files are
 * being uploaded to
 *
 * @var string
 */
$host = HOST.$server->path;


/**
 * Date/time string to use for reporting when deployment was
 * last run
 *
 * @var string
 */
define('FANCY_DATE', 'H:i:s \o\n l, \t\h\e jS \o\f F Y');

/**
 * Absolute path to template bash script
 *
 * @var string
 */
define('TMPL', __DIR__.DIRECTORY_SEPARATOR.'deploy-to.tmpl.sh');

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
    $tmpl = realpath(TMPL);

    if (!is_file($tmpl)) {
        trigger_error(
            'Could not find bash script template file at "'.TMPL.'"',
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
        getDeployable($data->sourceList[$a], $sinceTime)
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

// Build a list of calls to SCP
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
