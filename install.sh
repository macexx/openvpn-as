#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

#Add user for openvpn server to get uuid 1000
useradd -s /sbin/nologin openvpn_as

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh


#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe restricted' > /etc/apt/sources.list
echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates main universe restricted' >> /etc/apt/sources.list


# Install Dependencies
apt-get update -qq
apt-get install -qy iptables curl rsync

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Initiate install directory
mkdir -p /usr/local/openvpn_as


#########################################
##             INTALLATION             ##
#########################################

# Install OpenVPN-AS
curl -O http://swupdate.openvpn.org/as/openvpn-as-2.0.17-Ubuntu14.amd_64.deb
dpkg -i openvpn-as-2.0.17-Ubuntu14.amd_64.deb

# Copy Installed files to temp directory to later be copied to host directory in start script
chown -R openvpn_as:users /usr/local/openvpn_as
chmod 755 -R /usr/local/openvpn_as
rsync -a /usr/local/openvpn_as /tmp


#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
rm openvpn-as-2.0.17-Ubuntu14.amd_64.deb
