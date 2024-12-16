#!/usr/bin/env node
import { resolve } from 'path';
import { program } from 'commander';

import { executeCommand } from './utils';

const scriptPath = resolve(__dirname, './bash/generate-changelog.sh');

program
  .version('1.0.0')
  .description('Receiving arguements')
  .option('--projectUrl <url>', 'Specify the project url')
  .option('--title <title>', 'Specify the project title')
  .option('--pr', 'Export prelease logs')
  .option('--prTag <tag>', 'Specify the pre-release tag identifier')
  .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
  .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
  .option('--filterCommit <message>', 'Filter commits which contains specific words', '')
  .option('--note <note>', 'Specify publish note', '')
  .option('--ver <ver>', 'Specify version to publish', '')
  .action((options) => {
    if (!options?.projectUrl) {
      console.error('Exit: Arguemnt --projectUrl is required.')
      return
    }

    if (options?.pr && !options?.prTag) {
      console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag.')
      return
    }

    if (!options?.note && options?.ver) {
      console.error('Exit: Arguemnts --note is required to apply publish note.')
      return
    }

    if (options?.note && !options?.ver) {
      console.error('Exit: Arguemnts --ver is required to define version.')
      return
    }

    if (String(options?.note).includes(',')) {
      console.error(`Exit: Arguement --note does not allow ','.`)
      return
    }

    const projectUrlArg = options?.projectUrl ? `"${options.projectUrl}"` : `""`;
    console.log(`Project url: ${projectUrlArg}`);

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

    const filterCommitArg = `"${options.filterCommit}"`
    console.log(`Filter commit: ${filterCommitArg}`)

    const noteArg = `"${options.note}"`
    const versionArg = `"${options.ver}"`
    if (options?.note && options?.ver) {
      console.log(`Publish note: ${noteArg}`)
      console.log(`Publish version: ${versionArg}`)
    }

    executeCommand(`chmod +x ${scriptPath}`)

    const command = `bash "${scriptPath}" ${projectUrlArg} ${titleArg} ${prArg} ${prTagArg} ${filterTagArg} ${outDirArg} ${filterCommitArg} ${noteArg} ${versionArg}`
    executeCommand(command)
  });

  program.parse(process.argv);