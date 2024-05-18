ARG USER_NAME='app'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'
ARG REPO='githunb.com/b01/dl-vscode-server'
ARG WD="/home/${USER_NAME}/src/${REPO}/test/debian"

# VS Code, unfortunately, relies on GNU Lib C. So see if we can use Kohirens Alpine GNU LibC image.
FROM debian:bookworm-slim

ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_GROUP
ARG REPO
ARG WD

WORKDIR /tmp

# VS Code Server requirements: openssh, musl, libgcc, libstdc++
# For details see: https://code.visualstudio.com/docs/remote/linux
RUN apt-get -qq update -qq && apt-get -qq install -qq \
    ca-certificates \
    curl \
    git \
    gnupg \
    python3 \
    ssh \
&& apt-get -qq update \
 && rm -rf /var/lib/apt/lists/*

COPY --chmod=+x test/alpine/start.sh /usr/local/bin

HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "healthy" || exit 1

ENTRYPOINT [ "start.sh" ]

# Add a non-root group and user to runas
RUN addgroup --gid ${USER_GID} ${USER_GROUP} \
 && adduser --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME}

USER ${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} --chmod=+x download-vs-code.sh /tmp

# Install VS Code Server
RUN /tmp/download-vs-code.sh "linux" "x64" --dump-version
# Install VS Code CLI
RUN /tmp/download-vs-code.sh "linux" "x64" --dump-version --cli

WORKDIR ${WD}
