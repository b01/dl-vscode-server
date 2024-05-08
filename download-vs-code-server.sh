#!/bin/sh

# Copyright 2024 Khalifah K. Shabazz
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

set -e

# Auto-Get the latest commit sha via command line.
get_latest_release() {
    platform=${1}
    arch=${2}

    # Grab the first commit SHA since as this script assumes it will be the
    # latest.
    platform="win32"
    arch="x64"
    commit_id=$(curl --silent "https://update.code.visualstudio.com/api/commits/stable/${platform}-${arch}" | sed s'/^\["\([^"]*\).*$/\1/')

    printf "%s" "${commit_id}"
}

PLATFORM="${1}"
ARCH="${2}"
RETURN_VERSION="${3}"

# Platform is required
if [ -z "${PLATFORM}" ]; then
    echo "please enter a platform, acceptable values are win32, linux, darwin, or alpine"
    exit 1
fi

# if non specified, then guess
if [ -z "${ARCH}" ]; then
    U_NAME=$(uname -m)

    if [ "${U_NAME}" = "aarch64" ]; then
        ARCH="arm64"
    elif [ "${U_NAME}" = "x86_64" ]; then
        ARCH="x64"
    elif [ "${U_NAME}" = "armv7l" ]; then
        ARCH="armhf"
    fi
fi

commit_sha=$(get_latest_release "${PLATFORM}" "${ARCH}")

if [ -n "${commit_sha}" ]; then
    echo "will attempt to download and pre-configure VS Code Server version '${commit_sha}'"

    # Downloads VS Code with the server built in, not sure how to use that yet or if it possible since VS code client
    # or the remote extension seems to verify specifics files, like "node"
    prefix="server-${PLATFORM}"
    # TODO: Find the correct download location for Alpine, this is just the code cli, which does have the sever built in,
    # but the tar does not contain any other files that are required for a proper install.
    # There is a clue when the remote extension installs the server, but it does not reveal the URL where it downloads
    # it from. Instead it seems to copy it to the container then used the `dd` command to transfer it to the container,
    # strange indeed.
    # I don't understand why Alpine is still considered experimental other that the fact that some extensions require
    # glibc, but the same would be the case for extensions that require python or something else.
    # Keeping this for now as it was requested. But we need the correct URL. But it does not seem to work as far as
    # I've tested.
    if [ "${PLATFORM}" = "alpine" ]; then
        echo "NOTICE! Alpine is experimental"
        prefix="cli-${PLATFORM}"
    fi

    archive="vscode-${prefix}-${ARCH}.tar.gz"
    printf "%s" "downloading ${archive}..."
    # Download VS Code Server tarball to tmp directory.
    curl -s --fail -L "https://update.code.visualstudio.com/commit:${commit_sha}/${prefix}-${ARCH}/stable" -o "/tmp/${archive}"
#    curl -s --fail -L "https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-linux-x64/stable" -o "/tmp/${archive}"
    echo "done"

    echo "setup directories:"
    # Make the parent directory where the server should live.
    # NOTE: VS Code will runas the logged in user, so ensure they have read/write to the following directories
    mkdir -vp ~/.vscode-server/bin/"${commit_sha}"
    # VSCode Requirements for pre-installing extensions
    mkdir -vp ~/.vscode-server/extensions
    # found this in the VSCode remote extension output when connecting to an existing container
    mkdir -vp ~/.vscode-server/extensionsCache

    echo "done"

    # Extract the tarball to the right location.
    printf "%s" "extracting ${archive}..."
    tar -xz -C ~/.vscode-server/bin/"${commit_sha}" --strip-components=1 --no-same-owner -f "/tmp/${archive}"
    echo "done"

    # Add symlinks
    printf "%s" "setup symlinks..."
    cd ~/.vscode-server/bin && ln -s "${commit_sha}" default_version
    echo "done"

    # Used for testing script
    if [ "${RETURN_VERSION}" = "yes" ]; then
      ln -s "${HOME}"/.vscode-server/bin/"${commit_sha}"/bin/code-server "${HOME}"/code-server
      echo "${commit_sha}" > "${HOME}"/vs-code-version.txt
    fi

    echo "VS Code server pre-install completed"
else
    echo "could not pre install vscode server"
fi
