#!/bin/sh
set -e

# You can get the latest commit ID by looking at the latest tagged commit here: https://github.com/microsoft/vscode/releases
commit_id="08a217c4d27a02a5bcde898fd7981bda5b49391b"
hash="1618073181175" # This is not required, but I keep it around.
archive="vscode-server-linux-x64.tar.gz"
owner='microsoft'
repo='vscode'

# Get the latest commit sha via command line
get_latest_release() {
    tag=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
          grep '"tag_name":'                                              | # Get tag line
          sed -E 's/.*"([^"]+)".*/\1/'                                    ) # Pluck JSON value

    tag_data=$(curl --silent "https://api.github.com/repos/${1}/git/ref/tags/${tag}")

    sha=$(echo "${tag_data}"           | # Get latest release from GitHub api
          grep '"sha":'                | # Get tag line
          sed -E 's/.*"([^"]+)".*/\1/' ) # Pluck JSON value

    sha_type=$(echo "${tag_data}"           | # Get latest release from GitHub api
          grep '"type":'                    | # Get tag line
          sed -E 's/.*"([^"]+)".*/\1/'      ) # Pluck JSON value

    if [ $sha_type != "commit" ]; then
        combo_sha=$(curl -s "https://api.github.com/repos/${1}/git/tags/${sha}" | # Get latest release from GitHub api
              grep '"sha":'                                                     | # Get tag line
              sed -E 's/.*"([^"]+)".*/\1/'                                      ) # Pluck JSON value

        # Remove the tag sha, leaving only the commit sha; this won't work if there are ever more than 2 sha
        sha=$(echo $combo_sha | sed -E "s/${sha}//")
    fi

    printf "${sha}"
}

# Get the latest commit sha via command line
get_latest_release_jq() {
    tag=$(curl -s "https://api.github.com/repos/${1}/releases/latest" | jq -r '.tag_name')
    tag_data=$(curl -s "https://api.github.com/repos/${1}/git/ref/tags/${tag}" | jq -r '.object.type,.object.sha')

    # See: https://wiki-dev.bash-hackers.org/syntax/pe#substring_removal
    sha_type=${tag_data%$'\n'*}
    sha=${tag_data##*$'\n'}

    if [ "${sha_type}" != "commit" ]; then
        sha=$(curl -s "https://api.github.com/repos/${1}/git/tags/${sha}" | jq '.object.sha')
    fi

    printf "${sha}"
}

# Get the latest commit sha via command line
get_latest_release_graphql_jq() {
    sha=$(curl -s -H "Authorization: token $3" \
        -H  "Content-Type:application/json" \
        -d '{
            "query": "{repository(owner:\"'"$1"'\", name:\"'"$2"'\"){latestRelease{tagCommit {oid}}}}"
        }' https://api.github.com/graphql | jq -r '.data.repository.latestRelease.tagCommit.oid')

    printf "${sha}"
}

commit_sha=$(get_latest_release "${ownder}/${repo}")
echo "commit sha = ${commit_sha}"

commit_sha=$(get_latest_release_jq "${ownder}/${repo}")
echo "commit sha = ${commit_sha}"

if [ -n "${GITHUB_API_TOKEN}" ]; then
    commit_sha=$(get_latest_release_jq "${ownder}" "${repo}" "${GITHUB_API_TOKEN}")
    echo "commit sha = ${commit_sha}"
fi

# Download VS Code Server tarball to tmp directory.
curl -sSL "https://update.code.visualstudio.com/commit:${commit_id}/server-linux-x64/stable" -o "/tmp/${archive}"

# Make the parent directory where the server should live. NOTE: Ensure VS Code will have read/write access; namely the user running VScode or container user.
mkdir -p ~/.vscode-server/bin/${commit_id}_${hash}

# Extract the tarball to the right location.
tar --no-same-owner -xz --strip-components=1 -C ~/.vscode-server/bin/${commit_id}_${hash} -f /tmp/${archive}

# Move the server to the expected location, not sure why we don't just untar it there though.
mv -n ~/.vscode-server/bin/${commit_id}_${hash} ~/.vscode-server/bin/${commit_id}
