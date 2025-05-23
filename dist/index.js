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
    .option('--projectUrl <url>', 'Specify the project url')
    .option('--title <title>', 'Specify the project title')
    .option('--pr', 'Export prelease logs')
    .option('--prTag <tag>', 'Specify the pre-release tag identifier')
    .option('--filterTag <fTag>', 'Specify the tag name to be filtered')
    .option('--filterOutTag <fOutTag>', 'Specify the tag name to be filtered out')
    .option('--outDir <dir>', 'Specify an output folder for CHANGELOG', '.')
    .option('--filterCommit <message>', 'Filter commits which contains specific words', '')
    .option('--note <note>', 'Specify publish note', '')
    .option('--ver <ver>', 'Specify version to publish', '')
    .action((options) => {
    if (!(options === null || options === void 0 ? void 0 : options.projectUrl)) {
        console.error('Exit: Arguemnt --projectUrl is required.');
        return;
    }
    if ((options === null || options === void 0 ? void 0 : options.pr) && !(options === null || options === void 0 ? void 0 : options.prTag)) {
        console.error('Exit: Arguemnt --prTag is required to identifed pre-release tag.');
        return;
    }
    if (!(options === null || options === void 0 ? void 0 : options.note) && (options === null || options === void 0 ? void 0 : options.ver)) {
        console.error('Exit: Arguemnts --note is required to apply publish note.');
        return;
    }
    if ((options === null || options === void 0 ? void 0 : options.note) && !(options === null || options === void 0 ? void 0 : options.ver)) {
        console.error('Exit: Arguemnts --ver is required to define version.');
        return;
    }
    if (String(options === null || options === void 0 ? void 0 : options.note).includes(',')) {
        console.error(`Exit: Arguement --note does not allow ','.`);
        return;
    }
    const projectUrlArg = (options === null || options === void 0 ? void 0 : options.projectUrl) ? `"${options.projectUrl}"` : `""`;
    console.log(`Project url: ${projectUrlArg}`);
    const titleArg = (options === null || options === void 0 ? void 0 : options.title) ? `"${options.title}"` : `""`;
    console.log(`Title: ${titleArg}`);
    const prTagArg = (options === null || options === void 0 ? void 0 : options.prTag) ? `"${options.prTag}"` : `""`;
    console.log(`Enable pre-release mode: ${(options === null || options === void 0 ? void 0 : options.prTag) ? "true" : "false"}`);
    const prArg = (options === null || options === void 0 ? void 0 : options.pr) ? `"true"` : `"false"`;
    console.log(`Export pre-release logs? ${prArg}`);
    const filterTagArg = (options === null || options === void 0 ? void 0 : options.filterTag) ? `"${options.filterTag}"` : `""`;
    if (options === null || options === void 0 ? void 0 : options.filterTag) {
        console.log(`Filter tag: ${(options === null || options === void 0 ? void 0 : options.filterTag) ? filterTagArg : "-"}`);
    }
    const filterOutTagArg = (options === null || options === void 0 ? void 0 : options.filterOutTag) ? `"${options.filterOutTag}"` : `""`;
    if (options === null || options === void 0 ? void 0 : options.filterOutTag) {
        console.log(`Filter out tag: ${options.filterOutTag}`);
    }
    const outDirArg = `"${options.outDir}"`;
    console.log(`Output directory: ${outDirArg}`);
    const filterCommitArg = `"${options.filterCommit}"`;
    if (options === null || options === void 0 ? void 0 : options.filterCommit) {
        console.log(`Filter commit: ${filterCommitArg}`);
    }
    const noteArg = `"${options.note}"`;
    const versionArg = `"${options.ver}"`;
    if ((options === null || options === void 0 ? void 0 : options.note) && (options === null || options === void 0 ? void 0 : options.ver)) {
        console.log(`Publish note: ${noteArg}`);
        console.log(`Publish version: ${versionArg}`);
    }
    (0, utils_1.executeCommand)(`chmod +x ${scriptPath}`);
    const command = `bash "${scriptPath}" ${projectUrlArg} ${titleArg} ${prArg} ${prTagArg} ${filterTagArg} ${filterOutTagArg} ${outDirArg} ${filterCommitArg} ${noteArg} ${versionArg}`;
    (0, utils_1.executeCommand)(command);
});
commander_1.program.parse(process.argv);
