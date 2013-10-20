#!/bin/bash
# Author: @lorello
# Original Author: @HKirste
# Date: 26/08/2013
# Version 0.2
#
#
TYPE="allow"
CRON="/etc/cron.d/cf.cron"
LOCATION="/usr/local/cf"
IPT_LOCATION="/sbin/iptables"
PORTS="80,443"
CURRENT=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")");

addtocron() {
    rm -f $CRON
    sleep 1
    service crond restart
    sleep 1
    echo "SHELL=/bin/sh" > $CRON
    echo "0 0 * * * $LOCATION >/dev/null 2>&1" >> $CRON
    service crond restart
}

install() {
    if [ ! -f $LOCATION ];
    then
            mv $CURRENT $LOCATION
    fi

    addtocron
    echo 'CF auto IPs has been installed'
    echo 'This script has been created by @HKirste'
}

showhelp() {
    echo 'Usage: cf.sh [OPTIONS]'
    echo 'OPTIONS:'
    echo '-h | --help: Show this help screen'
    echo '-i | --install: Installs this script'
    echo '-c | --cron: Create cron job to run this script daily'
    echo '-t | --type: Choose between denying or allowing CF ips. Default: Allow. Valid input: ALLOW - DENY'
}

while [ $1 ]; do
    case $1 in
        '-h' | '--help' | '?')
            showhelp
            exit
        ;;
        '-c' | '--cron' )
            addtocron
            exit
        ;;
        '--install' )
            install
            exit
        ;;
        '-t' | '--type' )
            TYPE = $1
            if [ "$TYPE" != "deny" -o "$TYPE" != "DENY" -o "$TYPE" != "allow" -o "$TYPE" != "ALLOW" ]; then
                TYPE="allow"
            fi
        ;;
        * )
            showhelp
            exit
        ;;
esac
    shift
done

if [ ! -f $LOCATION ]; then
    install
fi

for line in `curl --silent https://www.cloudflare.com/ips-v4`; do

if [ "$TYPE" == "allow" -o "$TYPE" == "ALLOW" ]; then
    if [ UFW ]; then
        ufw allow proto tcp from $line to any port $PORTS
    else
        $IPT -I INPUT -s $CURR_LINE_IP -j ALLOW
    fi
elif [ "$TYPE" == "deny" -o "$TYPE" == "DENY" ]; then
    if [ UFW ]; then
        ufw deny proto tcp from $line to any port 80,443
    else
        $IPT -I INPUT -s $CURR_LINE_IP -j DROP
    fi
fi

done
