#!/bin/bash

################################################
##                  ADD USERS                 ##
################################################

# Set password for Web admin login
echo openvpn:$ADMIN_PASS|chpasswd

# Add vpn users
id -u $VPN_USER1 > /dev/null 2>&1 || useradd -s /sbin/nologin $VPN_USER1
id -u $VPN_USER2 > /dev/null 2>&1 || useradd -s /sbin/nologin $VPN_USER2

# Set passwords for vpn users
id -u $VPN_USER1 > /dev/null 2>&1 && echo $VPN_USER1:$VPN_PASS1|chpasswd
id -u $VPN_USER2 > /dev/null 2>&1 && echo $VPN_USER2:$VPN_PASS2|chpasswd


################################################
##   COPY DATA TO HOST AND SET PERMISSIONS    ##
################################################

# Copy configuration files to host directory and clean out tempfiles
if [ -d "/tmp/openvpn_as" ]; then
    rsync -a --ignore-existing /tmp/openvpn_as /usr/local && rm -r /tmp/openvpn_as
else
    echo "Nothing to Move!, Continuing..."
fi

# Make sure permissions for unRAID is ok
chown -R openvpn_as:users /usr/local/openvpn_as
chmod 755 -R /usr/local/openvpn_as


################################################
##               START OPENVPN                ##
################################################

# Start openvpn access server
service openvpnas restart
