#!/usr/bin/env node
import { resolve } from 'path';
import { program } from 'commander';

import { executeCommand } from './utils';

const scriptPath = resolve(__dirname, './bash/generate-changelog.sh');

program
  .version('1.0.0')
  .description('Receiving arguements')
  .option('--project <project>', 'Specify the project identifier on SCM platform')
  .option('--title <title>', 'Specify the project title')
  .option('--pr', 'Export prelease logs')
  .option('--prTag <tag>', 'Specify the pre-release tag identifier')
  .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
  .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
  .action((options) => {
    const projectArg = options?.project ? `"${options.project}"` : `""`;
    console.log(`Project name: ${projectArg}`);

    const titleArg = options?.title ? `"${options.title}"` : `""`;
    console.log(`Title: ${titleArg}`);

    const prArg = options?.pr ? `"true"` : `"false"`;
    console.log(`Export pre-release logs? ${prArg}`)

    const prTagArg = options?.prTag ? `"${options.prTag}"` : `""`
    console.log(`Is pre-release mode: ${options?.prTag ? "true" : "false"}`)

    const filterTagArg = options?.filterTag ? `"${options.filterTag}"` : `""`
    console.log(`Filter tag: ${options?.filterTag ? filterTagArg : "-"}`)

    const outDirArg = `"${options.outDir}"`
    console.log(`Output directory: ${outDirArg}`)

    if (options?.pr && !options?.prTag) {
      console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag.')
      return
    }

    executeCommand(`chmod +x ${scriptPath}`)

    const command = `bash "${scriptPath}" ${projectArg} ${titleArg} ${prArg} ${prTagArg} ${filterTagArg} ${outDirArg}`
    executeCommand(command)
  });

  program.parse(process.argv);