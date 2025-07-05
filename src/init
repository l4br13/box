PROGRAM=box
VERSION="1.2"
OS=$(uname -o)
ARCH=$(uname -m)

if [ $OS = "Android" ]; then
    if [ $(id -u) = 0 ]; then
        printf "$PROGRAM: must not be superuser to run command.\n"
        exit 1
    fi
    DIR=$PREFIX/var/lib/$PROGRAM
    TMP=$PREFIX/tmp
    ROOT=$DIR/root
else
    if [ $(id -u) != 0 ]; then
        printf "$PROGRAM: must be superuser to run command.\n"
        exit 1
    fi
    DIR=/var/lib/$PROGRAM
    TMP=/tmp/$PROGRAM
    ROOT=$DIR/root
fi

trap EXIT EXIT
trap EXIT INT