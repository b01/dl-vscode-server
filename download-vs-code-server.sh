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
    echo "attempting to download and pre-install VS Code Server version '${commit_sha}'"

    archive="vscode-server-${PLATFORM}-${ARCH}.tar.gz"

    printf "%s" "downloading ${archive}..."
    # Download VS Code Server tarball to tmp directory.
    curl -s --fail -L "https://update.code.visualstudio.com/commit:${commit_sha}/server-${PLATFORM}-${ARCH}/${BUILD}" -o "/tmp/${archive}"
    # Working URLs that helped derived format:
    # https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-linux-x64/stable
    # https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-darwin-x64/stable
    # https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-darwin-arm64/stable
    # https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-linux-alpine/stable
    # https://update.code.visualstudio.com/commit:b58957e67ee1e712cebf466b995adf4c5307b2bd/server-win32-x64/stable

    # NOTE: With this URL you can get Insider editions 't need the latest commit hash, as it always gets latest
    # https://update.code.visualstudio.com/commit:${commit_sha}/server-${PLATFORM}-${ARCH}/insider
    echo "done"

    echo "setup directories:"
    # Make the directories where the VS Code will search. There may be others not
    # listed here.
    # NOTE: VS Code will runas the logged in user, so ensure they have
    #       read/write to the following directories
    mkdir -vp ~/.vscode-server/bin/"${commit_sha}"
    # VSCode Requirements for pre-installing extensions
    mkdir -vp ~/.vscode-server/extensions
    # found this in the VSCode remote extension output when connecting to an existing container
    mkdir -vp ~/.vscode-server/extensionsCache
    # This should handle installs for https://vscode.dev/
    mkdir -vp ~/.vscode-server/cli/servers/Stable-"${commit_sha}"
    echo "done"

    # Extract the tarball to the right location.
    printf "%s" "extracting ${archive}..."
    tar -xz -C ~/.vscode-server/bin/"${commit_sha}" --strip-components=1 --no-same-owner -f "/tmp/${archive}"
    echo "done"

    # Add symlinks
    printf "%s" "setup symlinks..."
    ln -s ~/.vscode-server/bin/"${commit_sha}" ~/.vscode-server/bin/default_version
    ln -s ~/.vscode-server/bin/"${commit_sha}" ~/.vscode-server/cli/servers/Stable-"${commit_sha}"/server
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
