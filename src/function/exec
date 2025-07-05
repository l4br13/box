EXEC () {
    if [ -f $ROOT/etc/os-release ]; then
        . $ROOT/etc/os-release
        if [ "$ID" = "alpine" ]; then
            SH=sh
        elif [ "$ID" = "ubuntu" ]; then
            SH=bash
        fi
    fi

    if [ $(uname -o) = "Android" ]; then
        EXEC_PROOT "$*"
    else
        OLD_PATH=$PATH
        PATH=$OLD_PATH:/bin:/sbin:/usr/bin
        MOUNT
        chroot $ROOT $SH -c "$*" || {
            PATH=$OLD_PATH
            UMOUNT
            exit 1
        }
        PATH=$OLD_PATH
        UMOUNT
    fi
}