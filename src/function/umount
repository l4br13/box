UMOUNT () {
    if grep -qs $ROOT/proc /proc/mounts; then
        umount $ROOT/proc/
    fi
    if grep -qs $ROOT/sys /proc/mounts; then
        umount $ROOT/sys/
    fi
    if grep -qs $ROOT/dev /proc/mounts; then
        umount $ROOT/dev/pts
        umount $ROOT/dev/
    fi
    if grep -qs $ROOT/run /proc/mounts; then
        umount $ROOT/run/
    fi
    return 1
}