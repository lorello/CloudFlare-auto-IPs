CloudFlare-auto-IPs v0.2
========================

Automaticlly update your server's firewall to allow CloudFlare IPs

Features:
- Works with Ubuntu Firewall and IPtables
- Runs each day checking for new CloudFlare IPs to add

How to install:

wget https://raw.github.com/lorello/CloudFlare-auto-IPs/master/cf.sh
sh cf.sh

This will setup the script in your server to run each day checking for new IPs to add.

Please, verify that UFW is enabled, this script doesn't activate it.
