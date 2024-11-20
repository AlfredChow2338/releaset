import { executeCommand } from ".";

describe('execute command', () => {
  test('execute command with ls', done => { // Use done callback here
    executeCommand('ls', (error, stdout) => {
      expect(error).toBeNull();
      expect(stdout).toBeDefined();
      done(); // Notify Jest that the test is complete
    });
  });
});