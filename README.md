# DL VS Code Server

This script downloads a tar of VS Code Server/CLI, then extracts it to a
location expected by tunnels made by VS Code clients.

The intention of this script is to pre-install the VS Code binary during
container image build. This helps ensure, in certain scenarios, that the binary
is there when internet is not; while still allowing your VS Code client to
tunnel to the container.

When the VS Code binary is out-of-date, to get the latest version, re-run the
script.

## Background

The original reason was and still is to prevent the constant download and
install of VS Code server when the container is removed then run again later.
With the server being embedded in the image, it should also reduce time for the
dev container to be ready.

It originally started as a Gist; which you can review previous versions of the
script at [b01/download-vs-code-server.sh]

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/b01/dl-vscode-server/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/b01/dl-vscode-server/tree/main)

## How To Install

### Shell
```shell
curl -L https://raw.githubusercontent.com/b01/dl-vscode-server/main/download-vs-code-server.sh | bash -s -- "linux"
```

### Docker

```dockerfile
DL_VER="0.2.1"
# Install VS Code Server
RUN curl -LO https://raw.githubusercontent.com/b01/dl-vscode-server/refs/tags/${DL_VER}/download-vs-code.sh \
 && chmod +x download-vs-code.sh \
 && ./download-vs-code.sh "linux" "x64" --extensions "ms-vscode.cpptools"

# Install VS Code Server and Requirements
RUN ./download-vs-code.sh "linux" "x64" --alpine --extensions dbaeumer.vscode-eslint
```

## How To Use

`download-vs-code.sh [options] <PLATFORM> [<ARCH>]`

### Example:

download-vs-code.sh \"linux\" \"x64\" --alpine

### Options

`--insider`
Switches to the pre-released version of the binary chosen (server or
CLI).

`--dump-sha`
Will print the latest commit sha for VS Code (server and CLI are current
synced and always the same)

`--cli`
Switches the binary download VS Code CLI.

`--alpine`
Only works when downloading VS Code Server, it will force PLATFORM=linux and
ARCH=alpine, as the developers deviated from the standard format used for all
others.

`-h, --help`
Print this usage info

`--extensions`
    specify which extensions to install. expects a string of full extension names seperated by commas,
    e.g ms-vscode.PowerShell,redhat.ansible,ms-python.vscode-pylance


---

[b01/download-vs-code-server.sh]: https://gist.github.com/b01/0a16b6645ab7921b0910603dfb85e4fb
