# DL VS Code Server

This script downloads a tar of VS Code Server, then extracts it to a location expected by VS Code clients. The intention of this script is to download and setup the server during image build. This helps to ensure in certain scenarios that the server is there when internet is not, while still allowing your VS code client to connect to it.

Another reason is to prevent the constand download and install of VS Code server when the container is removed then run again later. With the sever being embeded in the image, it should not need to download until an update to VS Code itself, which would expect a new version of the server.

This originally started as a Gist. you can veiew previous version of this script at [b01/download-vs-code-server.sh]

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/b01/dl-vscode-server/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/b01/dl-vscode-server/tree/main)

## How To Use

You only need to download the script `download-vs-code-server.sh` and run it.

`download-vs-code-server.sh <PLATFORM> <ARCH>`

Example:

```shell
curl -L https://raw.githubusercontent.com/b01/dl-vscode-server/main/download-vs-code-server.sh | bash -s -- "linux"
```

---

[b01/download-vs-code-server.sh]: https://gist.github.com/b01/0a16b6645ab7921b0910603dfb85e4fb
