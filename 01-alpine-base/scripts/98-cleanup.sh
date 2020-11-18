#!/bin/sh -eux
set -eux

source /etc/profile
###export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

apk info --installed salt-minion && apkRESULT="${?}" || apkRESULT="${?}"
	if [[ $apkRESULT == "0" ]]; then
		rc-service salt-minion stop ||:
	fi


# #export CHROOT=/tmp/chroot
# export CHROOT=/tmp/chroot
# #PATH="$CHROOT/usr/local/sbin:$CHROOT/usr/local/bin:$CHROOT/usr/sbin:$CHROOT/usr/bin:$CHROOT/sbin:$CHROOT/bin:$PATH"
# export PATH="$PATH:$CHROOT/usr/local/sbin:$CHROOT/usr/local/bin:$CHROOT/usr/sbin:$CHROOT/usr/bin:$CHROOT/sbin:$CHROOT/bin"
# #export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/:/usr/lib/:/usr/lib64/:$CHROOT/usr/lib/:$CHROOT/lib/:$CHROOT/usr/local/lib/:$CHROOT/usr/lib64/:/usr/lib/:/lib/"
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib:/usr/lib:/usr/lib64:$CHROOT/usr/lib:$CHROOT/lib:$CHROOT/usr/local/lib:$CHROOT/usr/lib64:/usr/lib:/lib"
# export MIRROR=http://dl-cdn.alpinelinux.org/alpine
# export DIST_VER=edge
# #apk add --no-scripts -v -X http://dl-cdn.alpinelinux.org/alpine/edge/main --allow-untrusted --root $CHROOT --initdb -U --no-cache pv util-linux binutils coreutils busybox libacl libattr musl utmps
# apk add --no-scripts -v -X $MIRROR/$DIST_VER/main -X $MIRROR/$DIST_VER/community -X $MIRROR/$DIST_VER/testing --allow-untrusted --root $CHROOT --initdb -U --no-cache pv coreutils
# ldd $CHROOT/bin/ls
# ldd $CHROOT/bin/dd
# ldd $CHROOT/usr/bin/pv
# $CHROOT/bin/dd status=progress

rm -rf /var/cache/apk/* ||:
rm -rf /etc/ssh/ssh_host_* ||:
rm -rf /etc/dropbear/dropbear_host_* ||:
sync