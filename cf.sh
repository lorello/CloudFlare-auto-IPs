#!/bin/bash
# Author: @lorello
# Original Author: @HKirste
# Date: 26/08/2013
# Version 0.2
#
#
TYPE="allow"
CRON="/etc/cron.d/cloudflare-networks-refresh"
LOCATION="/usr/local/bin/cloudflare-networks-refresh"
IPT="/sbin/iptables"
PORTS="80,443"
CURRENT=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename -- "$0")");
UFW=`which ufw`

addtocron() {
  [ -f $CRON ] && rm -f $CRON
  echo "SHELL=/bin/sh" > $CRON
  echo "0 0 * * * [ -x $LOCATION ] && $LOCATION >/dev/null 2>&1" >> $CRON
  if [ -f $CRON ]; then
    echo -e "Cron setup finished successfully:\n\t$CRON\n"
  else
    echo -e "ERROR: unable to create cron entry in $CRON"
    exit 1
  fi
}

install() {
  if [ ! -f $LOCATION ];
  then
    cp $CURRENT $LOCATION
  fi
  if [ -f $LOCATION ]; then
    echo -e "CloudFlare ip refresher installed in\n\t$LOCATION\n"
    return 0
  else
    echo -e "ERROR: unable to install command in $LOCATION"
    exit 1
  fi 
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
      exit $?
      ;;
    '--install' )
      install
      exit $?
      ;;
    '-t' | '--type' )
      TYPE = $1
      if [ "$TYPE" != "deny" -o "$TYPE" != "DENY" -o "$TYPE" != "allow" -o "$TYPE" != "ALLOW" ]; then
        TYPE=allow
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
  addtocron
fi

for LINE in `curl --silent https://www.cloudflare.com/ips-v4`; do

  if [ "$TYPE" == "allow" -o "$TYPE" == "ALLOW" ]; then
    if [ UFW ]; then
      ufw allow proto tcp from $LINE to any port $PORTS
    else
      $IPT -I INPUT -s $LINE -j ALLOW
    fi
  elif [ "$TYPE" == "deny" -o "$TYPE" == "DENY" ]; then
    if [ UFW ]; then
      ufw deny proto tcp from $LINE to any port $PORTS 
    else
      $IPT -I INPUT -s $LINE -j DROP
    fi
  fi

done

