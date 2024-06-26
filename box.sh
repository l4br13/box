#!/bin/sh

PROGRAM=box
VERSION="1.0"
OS=$(uname -o)

if [ $OS != "Android" ]; then
	if [ $(id -u) != 0 ]; then
		printf "$PROGRAM: must be superuser to run command.\n"
		exit 1
	fi
	DIR=/var/lib/$PROGRAM
	TMP=/tmp/$PROGRAM
	ROOT=$DIR/root
elif [ $OS = "Android" ]; then
	if [ $(id -u) = 0 ]; then
		printf "$PROGRAM: must not be superuser to run command.\n"
		exit 1
	fi
	DIR=$PREFIX/var/lib/$PROGRAM
	TMP=$PREFIX/tmp
	ROOT=$DIR/root
fi

trap EXIT INT
trap EXIT EXIT

if [ ! -z $1 ]; then
	case $1 in
		-*)
			unset $EVAL
			unset $COMMAND
		;;
		*)
			EVAL=1
			COMMAND=$@
		;;
	esac
fi

if [ -z $EVAL ]; then
	OPT=$(getopt -n $PROGRAM -o 'hvil' -l help,version,install,login -- "$@")
	if [ $? -ne 0 ]; then
		printf "Try '$PROGRAM --help' for more information.\n"
		exit
	fi
	eval set -- $OPT
	while true; do
		if [ "$1" = "--" ]; then
			shift
			PARAM=$@
			break
		else
			case $1 in
				-h|--help)
					_HELP=1
				;;
				-v|--version)
					_VERSION=1
				;;
				-i|--install)
					_INSTALL=1
				;;
				-l|--login)
					_LOGIN=1
				;;
				*)
					break
				;;
			esac
		fi
		shift
	done
fi


# function 

EXIT () {
	UMOUNT
	exit 1
}

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
		fi
	fi
	if ! grep -qs $ROOT/run /proc/mounts; then
		if [ -d $ROOT/run ]; then
			mount -o bind /run $ROOT/run/
		fi
	fi
	return 1
}

UMOUNT () {
	if grep -qs $ROOT/proc /proc/mounts; then
		umount $ROOT/proc/
	fi
	if grep -qs $ROOT/sys /proc/mounts; then
		umount $ROOT/sys/
	fi
	if grep -qs $ROOT/dev /proc/mounts; then
		umount $ROOT/dev/
	fi
	if grep -qs $ROOT/run /proc/mounts; then
		umount $ROOT/run/
	fi
	return 1
}

HELP () {
	printf "Usage:	$PROGRAM [options] | [commands] <arguments>\n"
	printf "\n"
	printf "Options:\n"
	printf "	--install <distro>	install rootfs.\n"
	printf "	--login			login to rootfs.\n"
	printf "	--version		show version info.\n"
	printf "	--help			show help information.\n"
	printf "\n"
	return 1
}

VERSION () {
	printf "$PROGRAM v$VERSION\n"
	return 1
}

INSTALL () {
	if [ -f $ROOT/etc/os-release ]; then
		read -p "Are you sure want to reinstall (Y/n) : " confirm
		if [ "$CONFIRM" = "" ]; then CONFIRM="y"; fi
		if [ "$CONFIRM" = "Y" ]; then CONFIRM="y"; fi
		if [ "$CONFIRM" != "y" ]; then
			printf "install aborted.\n"
			exit 1
		fi
	fi

	if [ -z $* ]; then
		DISTRO=alpine
	elif [ "$*" = "alpine" ]; then
		DISTRO=alpine
	fi

	ARCH=$(uname -m)

	if [ "$DISTRO" = "alpine" ]; then
		URL=https://dl-cdn.alpinelinux.org
		MIRROR_URL=$URL/alpine/MIRRORS.txt
		MIRRORS=$(curl -s $MIRROR_URL --connect-timeout 10)
		REL=edge
		REL_URL=$URL/alpine/$REL/releases/$ARCH/latest-releases.yaml

		[ -d $DIR ] || mkdir $DIR

		[ -d $ROOT ] || mkdir $ROOT

		[ -d $TMP ] || mkdir $TMP

		UMOUNT

		rm -rf $ROOT/*

		LATEST_RELEASES="$(curl -fs $REL_URL --connect-timeout 10)"
		if [ "$LATEST_RELEASES" = "" ]; then
			printf "install error: internet connection.\n"
			exit
		fi
		echo "$LATEST_RELEASES" > $TMP/alpine-$REL-releases.yaml
		REL_VER=$(cat $TMP/alpine-$REL-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
		ROOTFS="alpine-minirootfs-${REL_VER}-${ARCH}.tar.gz"
		URL_ROOTFS=$URL/alpine/$REL/releases/$ARCH/$ROOTFS
		ROOTFS_FILE=$TMP/$ROOTFS
		if [ ! -f $TMP/$ROOTFS ]; then
			curl --progress-bar -L --fail --retry 4 $URL_ROOTFS -o $ROOTFS_FILE || {
				printf "install: error: failed to download file.\n"
				printf "installation aborted.\n"
				exit 1
			}
		fi
		if [ ! -f $TMP/$ROOTFS.sha256 ]; then
			curl --progress-bar -L --fail --retry 4 $URL_ROOTFS.sha256 -o $ROOTFS_FILE.sha256 || {
				printf "install: error: failed to download file.\n"
				exit 1
			}
		fi
		OLD_PWD=$PWD
		cd /tmp/box
		sha256sum --check --status ${ROOTFS}.sha256 || {
			rm -rf $ROOTFS_FILE
			rm -rf $ROOTFS_FILE.sha256
			printf "install error: downloaded file corrupted.\n"
			printf "installation aborted.\n"
			exit 1
		}
		cd $OLD_PWD
		tar -xf $ROOTFS_FILE -C $ROOT || {
			printf "install error: $ROOTFS corrupted."
			rm -rf $ROOTFS_FILE
			rm -rf $ROOTFS_FILE.sha256
			printf "installation aborted.\n"
			exit 1
		}
		cp $ROOT/etc/apk/repositories $ROOT/etc/apk/repositories.bak
		printf "https://dl-cdn.alpinelinux.org/alpine/$REL/main/\n" > $ROOT/etc/apk/repositories
		printf "https://dl-cdn.alpinelinux.org/alpine/$REL/community/\n" >> $ROOT/etc/apk/repositories
		printf "https://dl-cdn.alpinelinux.org/alpine/edge/testing/\n" >> $ROOT/etc/apk/repositories
		printf "nameserver 1.1.1.1" > $ROOT/etc/resolv.conf
		printf "alpine" > $ROOT/etc/hostname
		echo "PS1='\W \\$ ' " >> $ROOT/etc/profile
		echo 'cd $HOME' >> $ROOT/etc/profile
		#EXEC "apk update"
		#EXEC "apk upgrade"
		printf "$PROGRAM: install complete.\n"
	fi
}

EXEC () {
	if [ $OS = "Android" ]; then
		if [ ! -f $PREFIX/bin/proot ]; then
			printf "$program: proot not found, Abort.\n"
			exit 1
		fi
		unset LD_PRELOAD
		android=$(getprop ro.build.version.release)
		if [ ${android%%.*} -lt 8 ]; then
			[ $(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > $ROOT/etc/resolv.conf
		fi
		exec proot --link2symlink -0 -r $ROOT/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME -w /home /usr/bin/env TMPDIR=/tmp HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin sh -c "$*"
		return 1
	else
		OLD_PATH=$PATH
		PATH=$OLD_PATH:/bin:/sbin:/usr/bin
		MOUNT
		chroot $ROOT sh -c "$*" || {
			PATH=$OLD_PATH
			UMOUNT
			exit 1
		}
		PATH=$OLD_PATH
		UMOUNT
	fi
}

LOGIN () {
	if [ ! -f $ROOT/etc/os-release ]; then
		printf "$PROGRAM: is not installed.\n"
		printf "Try 'alpine --install' to install.\n"
		exit 1
	fi
	EXEC "sh --login"
}

if [ ! -z $EVAL ]; then
	if [ ! -f $ROOT/etc/os-release ]; then
		printf "$(basename $0): is not installed.\n"
		printf "Try '$(basename $0) --install' to install.\n"
		exit 1
	fi
	EXEC $COMMAND
else
	if [ ! -z $_HELP ]; then
		HELP
	elif [ ! -z $_VERSION ]; then
		VERSION
	elif [ ! -z $_INSTALL ]; then
		INSTALL $PARAM
	elif [ ! -z $_LOGIN ]; then
		LOGIN
	else
		LOGIN
	fi
fi