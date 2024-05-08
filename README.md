# DL VS Code Server

This script downloads a tar of VS Code Server, then extracts it to a location
expected by VS Code clients. The intention of this script is to download and
setup of the server during image build. This helps to ensure in certain
scenarios that the server is there when internet is not, while still allowing
your VS code client to connect to it.

To get the latest version of VS COde server, just rebuild the image.

## Background

The original reason was and still is to prevent the constant download and
install of VS Code server when the container is removed then run again later.
With the server being embedded in the image, it should also reduce time for the
dev container to be ready.

It originally started as a Gist; which you can review previous versions of the
script at [b01/download-vs-code-server.sh]

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/b01/dl-vscode-server/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/b01/dl-vscode-server/tree/main)

## How To Use

You only need to download the script `download-vs-code-server.sh` and run it.

`download-vs-code-server.sh <PLATFORM> <ARCH>`

Example:

```shell
curl -L https://raw.githubusercontent.com/b01/dl-vscode-server/main/download-vs-code-server.sh | bash -s -- "linux"
```

### Arguments

**PLATFORM** - Currently only `linux` or `alpine` are supported.

**ARCH** - Optional, will default to `uname -m`, which will map to a value
that Microsoft expects, so for, aarch64 => arm64, x86_64 => x64, and
armv7l => armhf. If you supply a value, that will be used without being mapped.

---

[b01/download-vs-code-server.sh]: https://gist.github.com/b01/0a16b6645ab7921b0910603dfb85e4fb
