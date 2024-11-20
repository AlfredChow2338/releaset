import { exec } from "child_process";

export function executeCommand(command: string, callback?: (error: any, stdout?: string, stderr?: string) => void): void {
  exec(command, (error, stdout, stderr) => {
      if (error) {
          console.error(`${error}`);
          callback?.(error);
          return;
      }
      if (stderr) {
          console.error(`${stderr}`);
          callback?.(new Error(stderr));
          return;
      }
      console.log(`${stdout}`);
      callback?.(null, stdout);
  });
}