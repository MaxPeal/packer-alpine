#!/bin/sh -eux
set -eux

source /etc/profile
###export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


#export CHROOT=/tmp/chroot
export CHROOT=/tmp/chroot
#PATH="$CHROOT/usr/local/sbin:$CHROOT/usr/local/bin:$CHROOT/usr/sbin:$CHROOT/usr/bin:$CHROOT/sbin:$CHROOT/bin:$PATH"
export PATH="$PATH:$CHROOT/usr/local/sbin:$CHROOT/usr/local/bin:$CHROOT/usr/sbin:$CHROOT/usr/bin:$CHROOT/sbin:$CHROOT/bin"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/:/usr/lib/:/usr/lib64/:$CHROOT/usr/lib/:$CHROOT/lib/:$CHROOT/usr/local/lib/:$CHROOT/usr/lib64/:/usr/lib/:/lib/"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib:/usr/lib:/usr/lib64:$CHROOT/usr/lib:$CHROOT/lib:$CHROOT/usr/local/lib:$CHROOT/usr/lib64:/usr/lib:/lib"
export LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/usr/lib64:$CHROOT/usr/lib:$CHROOT/lib:$CHROOT/usr/local/lib:$CHROOT/usr/lib64:/usr/lib:/lib"
export MIRROR="http://dl-cdn.alpinelinux.org/alpine"
export DIST_VER="edge"
#apk add --no-scripts -v -X http://dl-cdn.alpinelinux.org/alpine/edge/main --allow-untrusted --root $CHROOT --initdb -U --no-cache pv util-linux binutils coreutils busybox libacl libattr musl utmps
apk add -U -v -X $MIRROR/$DIST_VER/main -X $MIRROR/$DIST_VER/community -X $MIRROR/$DIST_VER/testing zerofree
apk add --no-scripts -v -X $MIRROR/$DIST_VER/main -X $MIRROR/$DIST_VER/community -X $MIRROR/$DIST_VER/testing --allow-untrusted --root $CHROOT --initdb -U --no-cache pv coreutils zerofree
ldd $CHROOT/bin/ls
ldd $CHROOT/bin/dd
ldd $CHROOT/bin/df
ldd $CHROOT/usr/bin/du
ldd $CHROOT/usr/bin/pv

rm -rf /var/cache/apk/* ||:
sync

#https://github.com/hashicorp/packer/blob/3d371a2d5dcda5144f018da35157090584d737c6/examples/_common/minimize.sh
# Whiteout root
#with gnu coreutils # count=$($CHROOT/bin/df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
#with busybox # count=$(sync && df -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(sync && df -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
$CHROOT/bin/dd if=/dev/zero of=/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
dd if=/dev/zero of=/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /whitespace

# Whiteout /boot
#with gnu coreutils # count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
#with busybox # count=$(sync && df -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(sync && df -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /boot/whitespace

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    /sbin/swapoff "$swappart";
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    /sbin/mkswap -U "$swapuuid" "$swappart";
fi


$CHROOT/bin/dd if=/dev/zero of=/EMPTY bs=1M status=progress conv=noerror,fsync ||:
#dd if=/dev/zero of=/EMPTY bs=1M
sync
rm -fr $CHROOT/
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
sync
sync
sleep 1
df -h
du -sh /*
exit 0
