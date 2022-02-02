<?php

/**
 * This file reads a user's .bashrc file and displays the aliases
 * as a human readable reference list of commands
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
// START: Initial validation

/**
 * Regular expression to find variable declarations in a .bashrc file.
 *
 * @var string FIND_VARS
 */
define(
    'FIND_VARS',
    '/(?<=^|[\r\n])(_?[a-z0-9]+)=([^;]+);?\s*(?=[\r\n]|$)/i'
);

/**
 * Regular expression to find blocks of alias declarations delimited
 * by a comment containing a string of hyphens or equals
 *
 * @var string FIND_BLOCKS
 */
define(
    'FIND_BLOCKS',
    '/# -(?: ?-)+ ?[\r\n]+# ([a-z ]+):?(.*?)(?=[\r\n]+(?:# [-=](?: ?[-=])+|$))/is'
);

/**
 * If user wishes to limit which aliases are shown they can pass a
 * string that matches the start of the label for a block of aliases
 *
 * @var string which
 */
$which = ($_SERVER['argc'] > 1)
    ? strtolower($_SERVER['argv'][1])
    : '';

/**
 * The length of user supplied block label
 */
$whichLen = strlen($which);

/**
 * List of $_SERVER keys that the user's home directory may be found
 *
 * @var array
 */
$keys = ['HOME', 'USERPROFILE'];

/**
 * Path to the user's home directory
 *
 * @var string
 */
$home = '';

for ($a = 0; $a < count($keys); $a += 1) {
    if (array_key_exists($keys[$a], $_SERVER)) {
        $home = realpath($_SERVER[$keys[$a]]);
        break;
    }
}

if ($home === '') {
    echo "\n\nCould not find path to user's home directory\n\n";
    exit;
}

/**
 * Path to the user's .bashrc file
 *
 * @var string
 */
$bashrc = $home.DIRECTORY_SEPARATOR.'.bashrc';

if (!is_file($bashrc)) {
    echo "\n\nCould not find path to user's .bashrc file\n\n";
    exit;
}


//  END:  Initial validation
// ===================================================================
// START: Helper functions


/**
 * Strip wrapping quote characters from strings
 *
 * @param string $input String to be stripped
 *
 * @return string
 */
function stripQuotes($input)
{
    return preg_replace(
        '/(?:\'([^\']*)\'|"([^"]*)")/',
        '\1\2',
        $input
    );
}

if (DIRECTORY_SEPARATOR === '\\') {
    /**
     * Fix the root path for windows file system paths
     *
     * @param string $input File system path to be fixed
     *
     * @return string
     */
    function winRoot($input)
    {
        return preg_replace_callback(
            '/^([\'"])?\/([a-z])(?=\/)/',
            function ($matches) {
                return $matches[1].strtoupper($matches[2]).':';
            },
            $input
        );
    }
} else {
    /**
     * Leave file system linux file system paths alone
     *
     * @param string $input File system path to be fixed
     *
     * @return string
     */
    function winRoot($input)
    {
        return $input;
    }
}

/**
 * Convert file system path to Windows file system path
 *
 * @param string $input File system path to be fixed
 *
 * @return string
 */
function winPath($input)
{
    if (substr_count($input, DIRECTORY_SEPARATOR)) {
        return preg_replace(
            '`\\'.DIRECTORY_SEPARATOR.'+`',
            DIRECTORY_SEPARATOR,
            str_replace(
                '/',
                DIRECTORY_SEPARATOR,
                $input
            )
        );
    } else {
        return $input;
    }
}

/**
 * Make sure the file system path is correct for the hosting system
 *
 * @param string $input File system path to be fixed
 *
 * @return string
 */
function cleanPath($input)
{
    $tmp = realpath(winRoot(stripQuotes($input)));
    if ($tmp === false) {
        return $input;
    } else {
        $tmp = (is_dir($tmp))
            ? $tmp.DIRECTORY_SEPARATOR
            : $tmp;
        return nonWin($tmp);
    }
}

/**
 * Replace variable names with the value assigned to that variable
 *
 * @param string $input String that may contain variable names
 *
 * @return string Full string
 */
function replaceVars($input)
{
    global $vars;
    $regex = '/\$(_?[a-z0-9_]+)/i';

    if (preg_match_all($regex, $input, $_vars, PREG_SET_ORDER)) {
        for ($b = 0; $b < count($_vars); $b += 1) {
            if (array_key_exists($_vars[$b][1], $vars)) {
                $input = str_replace(
                    $_vars[$b][0],
                    $vars[$_vars[$b][1]],
                    $input
                );
            }
        }
    }
    return $input;
}

/**
 * For linux commands we always want linux file system paths
 *
 * @param string $input File system path to be fixed
 *
 * @return string
 */
function nonWin($input)
{
    if (preg_match('/(?:\\\\bin\\\\sh|cd|tail|vim) /', $input)) {
        return preg_replace_callback(
            '/(?<=^| )([A-Z]):(?=\/)/',
            function ($matches) {
                return '/'.strtolower($matches[1]);
            },
            preg_replace('/\\\\/', '/', $input)
        );
    } else {
        return $input;
    }
}
/**
 * Convart list of alias strings to an array of key/value pairs
 * where the key is the alias name and the value is the command(s)
 * the alias calls
 *
 * @param string $input List of aliases
 *
 * @return array
 */
function aliasToArray(string $input) : array
{
    $regex4 = '/(?<=^|[\r\n])alias ([a-z0-9]+)=(.*?)(?=;?(?:[\r\n]|$))/i';
    $block = [];

    if (preg_match_all($regex4, $input, $aliases, PREG_SET_ORDER)) {
        for ($b = 0; $b < count($aliases); $b += 1) {
            $alias = $aliases[$b][1];

            $block[$alias] = nonWin(
                winPath(
                    stripQuotes(
                        replaceVars($aliases[$b][2])
                    )
                )
            );
        }
    }

    return $block;
}

/**
 * Render list of aliases as human readable string
 *
 * @param array $aliases Associative array of alias name/command
 *                       pairs
 *
 * @return string
 */
function renderAliases($aliases)
{
    $output = '';
    $len = 0;
    foreach ($aliases as $key => $value) {
        $a = strlen($key);
        if ($a > $len) {
            $len = $a;
        }
    }
    $len += 1;
    $newLine = "\n".str_pad('', $len + 4);

    ksort($aliases);

    foreach ($aliases as $key => $value) {
        $output .= renderSingleAlias($key, $value, $len, $newLine);
    }

    return $output;
}

/**
 * Render a single alias as human readable
 *
 * @param string  $alias   Alias name
 * @param string  $command Alias command (What the alias does)
 * @param integer $maxLen  Maximum length of any alias name in
 *                         the block
 * @param string  $newLine New line padded prefix
 *                         (used if alias has multiple parts)
 *
 * @return string
 */
function renderSingleAlias($alias, $command, $maxLen, $newLine)
{
    return  str_pad($alias, $maxLen).' -  '.
            preg_replace(
                '/([;&]) /',
                '\1'.$newLine,
                nonWin($command)
            ).
            "\n";
}


//  END:  Helper functions
// ===================================================================
// START: Procedural code

$content = str_replace(
    '$HOME',
    $home,
    file_get_contents($bashrc)
);

// Get variable names & values and put them into an array

$vars = [];

if (preg_match_all(FIND_VARS, $content, $matches, PREG_SET_ORDER)) {
    for ($a = 0; $a < count($matches); $a += 1) {
        $vars[$matches[$a][1]] = cleanPath(
            stripQuotes(
                replaceVars($matches[$a][2])
            )
        );
    }
}

// Find all the aliases and put them into an array and replace any
// variables calls with the value for that variable)

$outputAr = [];
$output = '';

if (preg_match_all(FIND_BLOCKS, $content, $blocks, PREG_SET_ORDER)) {
    for ($a = 0; $a < count($blocks); $a += 1) {
        $key = $blocks[$a][1];
        if ($whichLen === 0
            || strtolower(substr($key, 0, $whichLen)) === $which
        ) {
            // debug($key, $blocks[$a][2]);
            $block = aliasToArray($blocks[$a][2]);

            if (count($block) > 0) {
                $outputAr[$key] = $block;
            }

            if ($whichLen > 0) {
                break;
            }
        }
    }

    foreach ($outputAr as $label => $aliases) {
        $output .= "\n\n---------------------------------------".
                    "\n$label\n\n".
                    renderAliases($aliases);
    }
} else {
    $output = renderAliases($aliases);
}

// Render the output
echo $output;
