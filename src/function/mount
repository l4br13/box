MOUNT () {
    if ! grep -qs $ROOT/proc /proc/mounts; then
        if [ -d $ROOT/proc ]; then
            mount -t proc /proc $ROOT/proc/
        fi
    fi
    if ! grep -qs $ROOT/sys /proc/mounts; then
        if [ -d $ROOT/sys ]; then
            mount -t sysfs /sys $ROOT/sys/
        fi
    fi
    if ! grep -qs $ROOT/dev /proc/mounts; then
        if [ -d $ROOT/dev ]; then
            mount -o bind /dev $ROOT/dev/
            mount --rbind /dev/pts $ROOT/dev/pts
        fi
    fi
    if ! grep -qs $ROOT/run /proc/mounts; then
        if [ -d $ROOT/run ]; then
            mount -o bind /run $ROOT/run/
        fi
    fi
    return 1
}