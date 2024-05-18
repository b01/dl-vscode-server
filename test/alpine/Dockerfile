ARG USER_NAME='app'
ARG USER_UID='1000'
ARG USER_GID='1000'
ARG USER_GROUP='app_users'
ARG REPO='githunb.com/b01/dl-vscode-server'
ARG WD="/home/${USER_NAME}/src/${REPO}/test/alpine"

# VS Code, unfortunately, relies on GNU Lib C as may some extensions. Good news,
# we can use Kohirens Alpine GNU LibC image as base, it has GNY Lib C built for
# Alpine (in an Alpine container) and it works!
FROM kohirens/alpine-glibc:3.19-2.39

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
    file \
    git \
    gnupg \
    openssh \
    python3 \
&& apk --no-progress --purge --no-cache upgrade \
 && rm -vrf /var/cache/apk/*

HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "healthy" || exit 1

COPY --chmod=+x test/alpine/start.sh /usr/local/bin

ENTRYPOINT [ "start.sh" ]

# Add a non-root group and user to runas
RUN addgroup --system --gid ${USER_GID} ${USER_GROUP} \
 && adduser --system \
    --disabled-password \
    --ingroup ${USER_GROUP} \
    --uid ${USER_UID} \
    ${USER_NAME}

#RUN cat /etc/passwd \
# && sed -i '|(root:x:0:0:root:/root:)/bin/ash$|$1|g' /etc/passwd
USER ${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} --chmod=777 download-vs-code.sh /tmp

# Install VS Code Server
RUN /tmp/download-vs-code.sh "linux" "x64" --dump-version
RUN /tmp/download-vs-code.sh "linux" "x64" --dump-version --cli

WORKDIR ${WD}
