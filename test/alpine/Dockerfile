ARG USER_NAME='app'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'
ARG REPO='githunb.com/b01/dl-vscode-server'
ARG WD="/home/${USER_NAME}/src/${REPO}/test/alpine"

# VS Code, unfortunately, relies on GNU Lib C. So see if we can use Kohirens Alpine GNU LibC image.
FROM kohirens/alpine-glibc:3.19-2.39

ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_GROUP
ARG REPO
ARG WD

RUN apk --no-progress --purge --no-cache upgrade \
 && apk --no-progress --purge --no-cache add --upgrade \
    bash \
    curl \
    file \
    git \
    gnupg \
    openssh \
    python3 \
&& apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/*

# Add a non-root group and user to runas
RUN addgroup --system --gid ${USER_GID} ${USER_GROUP} \
 && adduser --system \
    --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME}

USER ${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} test/alpine/start.sh /usr/local/bin

HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "healthy" || exit 1

ENTRYPOINT [ "start.sh" ]

COPY --chown=${USER_NAME}:${USER_NAME} --chmod=777 download-vs-code-server.sh /tmp

# Install VS Code Server
RUN chmod +x /tmp/download-vs-code-server.sh \
 && /tmp/download-vs-code-server.sh "linux" "x64" "yes"

WORKDIR ${WD}
