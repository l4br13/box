EXEC_PROOT () {

     if [ -f $ROOT/etc/os-release ]; then
        . $ROOT/etc/os-release
        if [ "$ID" = "alpine" ]; then
            SH=sh
        elif [ "$ID" = "ubuntu" ]; then
            SH=bash
        fi
    fi
    
    if [ ! -f $PREFIX/bin/proot ]; then
        printf "$(basename $0): proot not found, Abort.\n"
        exit 1
    fi

    unset LD_PRELOAD
    android=$(getprop ro.build.version.release)
    if [ ${android%%.*} -lt 8 ]; then
        [ $(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > $ROOT/etc/resolv.conf
    fi
    exec proot --link2symlink -0 -r $ROOT/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME -w /home /usr/bin/env TMPDIR=/tmp HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin $SH -c "$*"
    return 1
}