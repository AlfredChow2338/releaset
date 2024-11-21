"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.executeCommand = executeCommand;
const child_process_1 = require("child_process");
function executeCommand(command, callback) {
    (0, child_process_1.exec)(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`${error}`);
            callback === null || callback === void 0 ? void 0 : callback(error);
            return;
        }
        if (stderr) {
            console.error(`${stderr}`);
            callback === null || callback === void 0 ? void 0 : callback(new Error(stderr));
            return;
        }
        console.log(`${stdout}`);
        callback === null || callback === void 0 ? void 0 : callback(null, stdout);
    });
}
