import * as fs from 'fs';
import * as process from 'process';

import {
  divideFiles,
  readDirRecurse,
  renderCmd,
} from './build-fix.functions.mjs'; // eslint-disable-line import/extensions

console.log('Building shell script for forward `buildfix`.')

const postAction = 'BUILD_FIX_ACTION.sh';

const src = process.argv[2];
// console.log('src:', src);

const { bad, dir, good } = divideFiles(
  readDirRecurse(src),
  (file) => (file.match(/\.bak$/)),
  `${src}/`
);


let outputData = renderCmd('remove', bad, 'rm');

if (good.length > 0 || dir.length > 0) {
  for (let a = 0; a < dir.length; a += 1) {
    const destFile = dir[a].replace(`${src}/`, '');
    // console.log('destFile:', destFile);

    if (fs.existsSync(dir[a]) === false) {
      outputData += `mkdir "${destFile}";\n`;
    }
  }

  for (let a = 0; a < good.length; a += 1) {
    const destFile = good[a].replace(`${src}/`, '');

    if (fs.existsSync(good[a])) {
      outputData += `cp "${good[a]}" "./${destFile}";\n`;
    }
  }

  fs.writeFileSync(postAction, `#!/bin/sh\n\n${outputData}`);
}
