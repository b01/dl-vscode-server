ARG USER_NAME='app'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'
ARG REPO='githunb.com/b01/dl-vscode-server'
ARG WD="/home/${USER_NAME}/src/${REPO}/test/alpine-musl"

FROM alpine:3.19

ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_GROUP
ARG REPO
ARG WD

WORKDIR /tmp

# VS Code Server requirements, for details see:
# https://code.visualstudio.com/docs/remote/linux
RUN apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    bash \
    curl \
    musl \
    libgcc \
    libstdc++ \
    openssh \
    python3 \
&& apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/*

COPY  --chmod=+x test/alpine/start.sh /usr/local/bin

HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "healthy" || exit 1

ENTRYPOINT [ "start.sh" ]

## Add a non-root group and user to runas
RUN addgroup --system --gid ${USER_GID} ${USER_GROUP} \
 && adduser --system \
    --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME}

USER ${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} --chmod=777 download-vs-code.sh /tmp

# Install VS Code Server
# NOTE: To download VS Code server use the --alpine flag to force PLATFORM="linux" and ARCH="alpine", the actual input will be ignored.
RUN /tmp/download-vs-code.sh "alpine" "x64" --dump-version --alpine
RUN /tmp/download-vs-code.sh "alpine" "x64" --dump-version --cli

WORKDIR ${WD}
