# About

This container is for testing out the pre-installed vscode server setup inside an Alpine contiainer.

This image uses the Kohirens [Alpine GLIBC] image as a base, so you get a real version of GNU LibC built in an Alpine container for Alpine. So it should not have issues running node for VS Code server. Beside the warning about libc++ not having any version info.

---

[Alpine GLIBC]: https://github.com/kohirens/docker-alpine-glibc
