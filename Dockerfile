FROM mumiehub/rclone-mount:latest

ENV GOPATH="/go" \
    AccessFolder="/mnt" \
    RemotePath="drive:" \
    MountPoint="/mnt" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty --dir-cache-time=1m  --cache-chunk-size=10M --cache-workers=5 --fast-list --vfs-cache-mode full" \
    UnmountCommands="-u -z"

## Alpine with Go Git
RUN apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev \
	&& go get -u -v github.com/ncw/rclone \
	&& cp /go/bin/rclone /usr/sbin/ \
	&& rm -rf /go \
	&& apk del alpine-sdk go git \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
RUN chmod +x /start.sh 

VOLUME ["/mnt"]

CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared