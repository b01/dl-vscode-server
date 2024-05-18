# Testing

The VS Code Server has a lot of location where it needs to reside for the many
different type of DevContainer setups. These instructions should provide how
to verify the script still works in those scenarios. Each heading below
represents a different scenario.
## Pre-requisites

1. Start Docker Desktop (or equivalent) if it has not been started already.
2. Clone this project locally and open it in VSCode.
3. In VS Code, open a terminal/shell (you should be in the project directory).

## Local VSCode To Local Container

## VSCode.dev

Start a test container, should not matter which one (we'll use Alpine for
this example):

1. `cd test/alpine-musl`
2. Run `docker compose up`
3. Login to the container: 
4. Create a secure tunnel with the tunnel command:
   ```shell
    ~/code tunnel --accept-server-license-terms
   ```
5. Perform all the action netting you a URL to vscode.dev, click the URL to
   open it in your browser.
6. Review the output in the terminal to verify no vscode server installation
   occurs.

## Web VSCode to Remote Container

Untested.

