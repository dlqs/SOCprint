#!/bin/sh


COMMAND="socprint"
COMMANDPATH="/usr/local/bin"

check_command_not_installed() {
    command -v $COMMAND >/dev/null 2>&1 && {
        error_message "SOCPrint has already been installed"
    }
}

check_curl_not_install() {
    command -v curl >/dev/null 2>&1 || {
        error_message "Please install curl"
    }
}

#CREDITS: From https://curlhub.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh
setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

error_message() {
    printf "%s[ERROR] %s%s" "$RED" "$@" "$RESET"
    exit 1
}

install() {
    curl https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh -o "$COMMANDPATH/$COMMAND"
    chmod 755 "$COMMANDPATH/$COMMAND"
}

check_root() {
    if ! [ "$(id -u)" = 0 ]; then
        error_message "This script must be run as root"
    fi
}

welcome_message() {
    printf "%s" "$GREEN"
    cat <<EOF
  /\$\$\$\$\$\$   /\$\$\$\$\$\$   /\$\$\$\$\$\$  /\$\$\$\$\$\$\$           /\$\$             /\$\$
 /\$\$__  \$\$ /\$\$__  \$\$ /\$\$__  \$\$| \$\$__  \$\$         |__/            | \$\$
| \$\$  \__/| \$\$  \ \$\$| \$\$  \__/| \$\$  \ \$\$ /\$\$\$\$\$\$  /\$\$ /\$\$\$\$\$\$\$  /\$\$\$\$\$\$
|  \$\$\$\$\$\$ | \$\$  | \$\$| \$\$      | \$\$\$\$\$\$\$//\$\$__  \$\$| \$\$| \$\$__  \$\$|_  \$\$_/
 \____  \$\$| \$\$  | \$\$| \$\$      | \$\$____/| \$\$  \__/| \$\$| \$\$  \ \$\$  | \$\$
 /\$\$  \ \$\$| \$\$  | \$\$| \$\$    \$\$| \$\$     | \$\$      | \$\$| \$\$  | \$\$  | \$\$ /\$\$
|  \$\$\$\$\$\$/|  \$\$\$\$\$\$/|  \$\$\$\$\$\$/| \$\$     | \$\$      | \$\$| \$\$  | \$\$  |  \$\$\$\$/
 \______/  \______/  \______/ |__/     |__/      |__/|__/  |__/   \___/
EOF
    printf "%s" "$RESET"
    printf "%s...to the moon%s\n" "$BLUE" "$RESET"

}

specify_path() {
    printf '%sSpecify a path to install SOCPrint [Default if no path specified: %s]%s' "$YELLOW" "$COMMANDPATH" "$RESET"
    read -r path
    [ -n "$path" ] && COMMANDPATH=$path
}

post_install_message () {
    printf '%sThank you for using SOCPrint! You may now run %s' "$GREEN" "$RESET"
    printf '%ssocprint%s' "$BOLD$YELLOW" "$RESET"
    printf "%s from any directory. If it does not work, please make sure that \"%s\" is in your \$PATH%s" "$GREEN" "$COMMANDPATH" "$RESET"
}

main() {
    setup_color
    check_root
    welcome_message
    check_command_not_installed
    check_curl_not_install
    specify_path
    install
    post_install_message
}

main "@"

exit 0
