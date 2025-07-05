LOGIN () {
    if [ ! -f $ROOT/etc/os-release ]; then
        printf "$PROGRAM: is not installed.\n"
        printf "Try '$(basename $0) --install' to install.\n"
        exit 1
    fi
    if [ -f $ROOT/etc/os-release ]; then
        . $ROOT/etc/os-release
        if [ "$ID" = "alpine" ]; then
            SH=sh
        elif [ "$ID" = "ubuntu" ]; then
            SH=bash
        fi
    fi
    if [ $(uname -o) = "Android" ]; then
        EXEC_PROOT "$SH --login"
    else
        EXEC "$SH --login"
    fi
}