INSTALL () {
    if [ -f $ROOT/etc/os-release ]; then
        . $ROOT/etc/os-release
        
        printf "$(basename $0): $NAME are installed.\n"
        
        read -p "Are you sure want to reinstall (Y/n) : " CONFIRM
        
        if [ "$CONFIRM" = "" ]; then CONFIRM="y"; fi
        if [ "$CONFIRM" = "Y" ]; then CONFIRM="y"; fi
        if [ "$CONFIRM" != "y" ]; then
            printf "install aborted.\n"
            exit 1
        fi
        echo 
    fi
    
    if [ "$*" = "alpine" ]; then
        INSTALL_ALPINE
    elif [ "$*" = "ubuntu" ]; then
        INSTALL_UBUNTU
    else
        INSTALL_ALPINE
    fi
    
    return 1
}