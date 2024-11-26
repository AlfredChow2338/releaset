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
    .option('--project <project>', 'Specify the project identifier on SCM platform')
    .option('--title <title>', 'Specify the project title')
    .option('--pr', 'Export prelease logs')
    .option('--prTag <tag>', 'Specify the pre-release tag identifier')
    .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
    .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
    .action((options) => {
    const projectArg = (options === null || options === void 0 ? void 0 : options.project) ? `"${options.project}"` : `""`;
    console.log(`Project name: ${projectArg}`);
    const titleArg = (options === null || options === void 0 ? void 0 : options.title) ? `"${options.title}"` : `""`;
    console.log(`Title: ${titleArg}`);
    const prArg = (options === null || options === void 0 ? void 0 : options.pr) ? `"true"` : `"false"`;
    console.log(`Export pre-release logs? ${prArg}`);
    const prTagArg = (options === null || options === void 0 ? void 0 : options.prTag) ? `"${options.prTag}"` : `""`;
    console.log(`Is pre-release mode: ${(options === null || options === void 0 ? void 0 : options.prTag) ? "true" : "false"}`);
    const filterTagArg = (options === null || options === void 0 ? void 0 : options.filterTag) ? `"${options.filterTag}"` : `""`;
    console.log(`Filter tag: ${(options === null || options === void 0 ? void 0 : options.filterTag) ? filterTagArg : "-"}`);
    const outDirArg = `"${options.outDir}"`;
    console.log(`Output directory: ${outDirArg}`);
    if ((options === null || options === void 0 ? void 0 : options.pr) && !(options === null || options === void 0 ? void 0 : options.prTag)) {
        console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag.');
        return;
    }
    (0, utils_1.executeCommand)(`chmod +x ${scriptPath}`);
    const command = `bash "${scriptPath}" ${projectArg} ${titleArg} ${prArg} ${prTagArg} ${filterTagArg} ${outDirArg}`;
    (0, utils_1.executeCommand)(command);
});
commander_1.program.parse(process.argv);
