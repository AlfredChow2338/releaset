"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const _1 = require(".");
describe('execute command', () => {
    test('execute command with ls', done => {
        (0, _1.executeCommand)('ls', (error, stdout) => {
            expect(error).toBeNull();
            expect(stdout).toBeDefined();
            done(); // Notify Jest that the test is complete
        });
    });
});
