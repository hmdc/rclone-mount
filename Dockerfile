FROM mumiehub/rclone-mount:latest

ENV GOPATH="/go" \
    RCLONE_VERSION="v1.49.1" \
    AccessFolder="/mnt" \
    RemotePath="drive:" \
    MountPoint="/mnt" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty --dir-cache-time=1m  --cache-chunk-size=10M --cache-workers=5 --fast-list --vfs-cache-mode full" \
    UnmountCommands="-u -z"

## Alpine with Go Git
RUN apk add --no-cache --update alpine-sdk ca-certificates fuse fuse-dev wget \
        && wget https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip -O /tmp/rclone.zip \
        && unzip -o -j /tmp/rclone.zip -d /usr/sbin \
	&& apk del alpine-sdk wget \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
RUN chmod +x /start.sh 

VOLUME ["/mnt"]

CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
