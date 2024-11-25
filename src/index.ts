#!/usr/bin/env node
import { resolve } from 'path';
import { program } from 'commander';

import { executeCommand } from './utils';

const scriptPath = resolve(__dirname, './bash/generate-changelog.sh');

program
  .version('1.0.0')
  .description('Receiving arguements')
  .option('--project <name>', 'Specify the project name')
  .option('--pr', 'Export prelease logs')
  .option('--prTag <tag>', 'Specify the pre-release tag identifier')
  .option('--repoUrl <url>', 'Specify the repo url')
  .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
  .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
  .action((options) => {
    const projectArg = options?.project ? `"${options.project}"` : `""`;
    console.log(`Project name: ${projectArg}`);

    const prArg = options?.pr ? `"true"` : `"false"`;
    console.log(`Export pre-release logs? ${prArg}`)

    const prTagArg = options?.prTag ? `"${options.prTag}"` : `""`
    if (options?.pr) {
      console.log(`Pr Tag: ${prTagArg}`)
    } 

    const repoUrlArg = options?.repoUrl ? `"${options.repoUrl}"` : `""`
    console.log(`Repo Url: ${repoUrlArg}`)

    const filterTagArg = options?.filterTag ? `"${options.filterTag}"` : `""`
    if (options?.filterTag) {
      console.log(`Filter tag: ${filterTagArg}`)
    }

    const outDirArg = `"${options.outDir}"`
    console.log(`Output directory: ${outDirArg}`)

    if (options?.pr && !options?.prTag) {
      console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag name.')
      return
    }

    executeCommand(`chmod +x ${scriptPath}`)

    const command = `bash "${scriptPath}" ${projectArg} ${prArg} ${prTagArg} ${repoUrlArg} ${filterTagArg} ${outDirArg}`
    executeCommand(command)
  });

  program.parse(process.argv);