#!/bin/sh

# Copyright 2023 Khalifah K. Shabazz
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

if [ -z "${PLATFORM}" ]; then
    echo "please enter a platform, acceptable values are win32, linux, darwin, or alpine"
    exit 1
fi

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
    echo "will attempt to download VS Code Server version = '${commit_sha}'"

    prefix="server-${PLATFORM}"
    if [ "${PLATFORM}" = "alpine" ]; then
        prefix="cli-${PLATFORM}"
    fi

    archive="vscode-${prefix}-${ARCH}.tar.gz"
    # Download VS Code Server tarball to tmp directory.
    curl -L "https://update.code.visualstudio.com/commit:${commit_sha}/${prefix}-${ARCH}/stable" -o "/tmp/${archive}"

    # Make the parent directory where the server should live.
    # NOTE: Ensure VS Code will have read/write access; namely the user running VScode or container user.
    mkdir -vp ~/.vscode-server/bin/"${commit_sha}"

    # Extract the tarball to the right location.
    tar --no-same-owner -xzv --strip-components=1 -C ~/.vscode-server/bin/"${commit_sha}" -f "/tmp/${archive}"
    # Add symlink
    cd ~/.vscode-server/bin && ln -s "${commit_sha}" default_version
else
    echo "could not pre install vscode server"
fi
