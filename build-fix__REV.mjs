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
const gitUntracked = 'BUILD_FIX_TMP-untracked.txt';
const postAction = 'BUILD_FIX_ACTION.sh';

const fixDir = process.argv[2];

// const gitFiles = readToArray(gitAll);
const gitChanged = readToArray(gitChange);
let fixFiles = readDirRecurse(fixDir);

const clean = new RegExp('^' + fixDir.replace(/(?=[.\/])/g, '\\'));
fixFiles = fixFiles.map((fileName) => fileName.replace(clean, ''));

const isBad = (_fixFiles, exists) => (untrackedFile) => {
  return (untrackedFile.match(/\.bak$/)
    || (_fixFiles.indexOf(untrackedFile) > -1
    && exists(untrackedFile)));
};

const { bad } = divideFiles(
  gitUntracked,
  isBad(
    fixFiles,
    fs.existsSync,
  ),
);

let outputData = '';

outputData += renderCmd('remove', bad, 'rm');
outputData += renderCmd('checkout', gitChanged, 'git checkout');

// console.log('outputData:', outputData);

if (outputData.trim() !== '') {
  fs.writeFileSync(postAction, `#!/bin/sh\n\n${outputData}`);
}
