FROM alpine:latest

ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH="amd64"
ARG GOPATH="/go"
ARG RCLONE_VERSION="v1.49.1"

ENV DEBUG="false" \
    GOPATH="/go" \
    AccessFolder="/mnt" \
    RemotePath="drive:" \
    MountPoint="/mnt" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty --dir-cache-time=1m  --cache-chunk-size=10M --cache-workers=5 --fast-list --vfs-cache-mode full" \
    UnmountCommands="-u -z"

## Alpine with Go Git
RUN apk --no-cache upgrade \
    && apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev gnupg curl wget \
    \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && wget https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip -O /tmp/rclone.zip \
    && unzip -o -j /tmp/rclone.zip -d /usr/sbin \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    \
    && ls -ltrd /tmp/* \
    && curl https://keybase.io/justcontainers/key.asc | gpg --import \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    \
    && echo "Cleaning up unnecessary packages and files." \
    && apk del alpine-sdk go git gnupg wget \
    && rm -rf /tmp/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

ADD start.sh /start.sh
RUN chmod +x /start.sh 

VOLUME ["/mnt"]

CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
