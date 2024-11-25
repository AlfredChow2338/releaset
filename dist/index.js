#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = require("path");
const commander_1 = require("commander");
const utils_1 = require("./utils");
const scriptPath = (0, path_1.resolve)(__dirname, './bash/generate-changelog.sh');
commander_1.program
    .version('1.0.0')
    .description('Receiving arguements')
    .option('--project <name>', 'Specify the project name')
    .option('--pr', 'Export prelease logs')
    .option('--prTag <tag>', 'Specify the pre-release tag identifier')
    .option('--repoUrl <url>', 'Specify the repo url')
    .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
    .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
    .action((options) => {
    const projectArg = (options === null || options === void 0 ? void 0 : options.project) ? `"${options.project}"` : `""`;
    console.log(`Project name: ${projectArg}`);
    const prArg = (options === null || options === void 0 ? void 0 : options.pr) ? `"true"` : `"false"`;
    console.log(`Export pre-release logs? ${prArg}`);
    const prTagArg = (options === null || options === void 0 ? void 0 : options.prTag) ? `"${options.prTag}"` : `""`;
    if (options === null || options === void 0 ? void 0 : options.pr) {
        console.log(`Pr Tag: ${prTagArg}`);
    }
    const repoUrlArg = (options === null || options === void 0 ? void 0 : options.repoUrl) ? `"${options.repoUrl}"` : `""`;
    console.log(`Repo Url: ${repoUrlArg}`);
    const filterTagArg = (options === null || options === void 0 ? void 0 : options.filterTag) ? `"${options.filterTag}"` : `""`;
    if (options === null || options === void 0 ? void 0 : options.filterTag) {
        console.log(`Filter tag: ${filterTagArg}`);
    }
    const outDirArg = `"${options.outDir}"`;
    console.log(`Output directory: ${outDirArg}`);
    if ((options === null || options === void 0 ? void 0 : options.pr) && !(options === null || options === void 0 ? void 0 : options.prTag)) {
        console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag name.');
        return;
    }
    (0, utils_1.executeCommand)(`chmod +x ${scriptPath}`);
    const command = `bash "${scriptPath}" ${projectArg} ${prArg} ${prTagArg} ${repoUrlArg} ${filterTagArg} ${outDirArg}`;
    (0, utils_1.executeCommand)(command);
});
commander_1.program.parse(process.argv);
