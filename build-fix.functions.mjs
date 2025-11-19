import * as fs from 'fs';
import * as path from 'path';

// ==================================================================
// START: Helper functions

const getWholeCmd = (cmd, list) => {
  const space = ''.padStart(cmd.length + 1);
  const joiner = `" \\\n${space}"`;

  return `${cmd} "${list.join(joiner)}";\n\n`;
};

export const readToArray = (fileName) => {
  const data = fs.readFileSync(fileName).toString().split('\n');
  const output = [];

  for (let a = 0; a < data.length; a += 1) {
    const tmp = data[a].trim();

    if (tmp !== '') {
      output.push(tmp);
    }
  }

  return output;
};

/**
 * Recursively read through a directory to find all the files
 *
 * NOTE: This function has a side effect where files ending in .bak
 *       are added to the `removeList` array
 *
 * @param {string}  dir   Path to directory
 * @param {boolean} first Whether or not this is the first time the
 *                        function is called
 *
 * @returns {string[]} List of all files (including files within
 *                     subdirectories) in the specified parent
 *                     directory.
 */
export const readDirRecurse = (dir) => {
  const prefix = `${dir}/`;

  const files = fs.readdirSync(dir);
  let output = [];

  for (let a = 0; a < files.length; a += 1) {
    const relPath = `${dir}/${files[a]}`;
    const filePath = path.resolve(dir, files[a]);

    const fileDetails = fs.lstatSync(filePath);

    if (fileDetails.isDirectory()) {
      output = [...output, `[DIR]${relPath}`, ...readDirRecurse(relPath, false)];
    } else {
      output.push(relPath);
    }
  }

  return output;
};

export const renderCmd = (cmd, list, rawCmd = null) => {
  const l = list.length;
  let output = '';
  const _cmd = (rawCmd === null)
    ? cmd
    : rawCmd;

  if (l > 0) {
    output += '\n# ==================================================================\n';
    output += `# About to ${cmd} ${l} file${(l > 1) ? 's' : ''}\n\n`;
    output += getWholeCmd(_cmd, list);
  }

  console.log('renderCmd() output:', output);

  return output;
};

export const divideFiles = (list, tester, prefix) => {
  const good = [];
  const bad = [];
  const dir = [];
  console.log('list:', list);

  for (let a = 0; a < list.length; a += 1) {
    if (list[a].substring(0, 5) === '[DIR]') {
      dir.push(list[a].substring(5).replace(prefix, ''));
  } else if (tester(list[a])) {
      bad.push(list[a]);
    } else {
      good.push(list[a]);
    }
  }

  return { bad, dir, good };
};
