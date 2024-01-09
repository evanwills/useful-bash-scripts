import * as fs from 'fs';
import * as process from 'process';
import {
  divideFiles,
  readToArray,
  readDirRecurse,
  renderCmd,
} from './build-fix.functions.mjs'; // eslint-disable-line import/extensions

console.log('Building shell script for reversing `buildfix`.')

const gitAll = 'BUILD_FIX_TMP-all.txt';
const gitChange = 'BUILD_FIX_TMP-changed.txt';
const postAction = 'BUILD_FIX_ACTION.sh';

const fixDir = process.argv[2];

const gitFiles = readToArray(gitAll);
const gitChanged = readToArray(gitChange);

const isBad = (gitFiles, exists) => (file) => (file.match(/\.bak$/)
  || (gitFiles.indexOf(file) === -1 && exists(file)));

const { bad } = divideFiles(
  readDirRecurse(fixDir),
  isBad(gitFiles, fs.existsSync),
);

let outputData = '';

outputData += renderCmd('remove', bad, 'rm');
outputData += renderCmd('checkout', gitChanged, 'git checkout');

if (outputData.trim() !== '') {
  fs.writeFileSync(postAction, `#!/bin/sh\n\n${outputData}`);
}
