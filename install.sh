#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home


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
apt-get install -qy iptables curl

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# Initiate config directory
mkdir -p /config


# OPENVPN_AS
mkdir -p /etc/service/openvpn
cat <<'EOT' > /etc/service/openvpn/run
#!/bin/bash
chown -R nobody:users /config
/usr/local/openvpn_as/scripts/openvpnas --nodaemon --logfile=/config/logs/openvpn.log
EOT


# Config
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash

# Set password for Web admin login
echo openvpn:$ADMIN_PASS|chpasswd

# Add vpn users
id -u $VPN_USER1 > /dev/null 2>&1 || useradd -s /sbin/nologin $VPN_USER1
id -u $VPN_USER2 > /dev/null 2>&1 || useradd -s /sbin/nologin $VPN_USER2

# Set passwords for vpn users
id -u $VPN_USER1 > /dev/null 2>&1 && echo $VPN_USER1:$VPN_PASS1|chpasswd
id -u $VPN_USER2 > /dev/null 2>&1 && echo $VPN_USER2:$VPN_PASS2|chpasswd

# Set log directory
mkdir -p /config/logs
touch /config/logs/openvpn.log

# Checking if openvpn configuration exists
if [ -d "/config/config/etc" ]; then
  echo "Config exists, importing previous configuration!"
  rm -r /usr/local/openvpn_as/etc
  ln -sf /config/config/etc /usr/local/openvpn_as/etc
else
  echo "Copying configuration from install directory to host!"
  mkdir -p /config/config
  mv /usr/local/openvpn_as/etc /config/config/etc
  ln -sf /config/config/etc /usr/local/openvpn_as/etc
fi

chown -R nobody:users /config
EOT


chmod -R +x /etc/service/ /etc/my_init.d/


#########################################
##             INTALLATION             ##
#########################################

# Install OpenVPN-AS
curl -O http://swupdate.openvpn.org/as/openvpn-as-2.0.17-Ubuntu14.amd_64.deb
dpkg -i openvpn-as-2.0.17-Ubuntu14.amd_64.deb



#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
rm openvpn-as-2.0.17-Ubuntu14.amd_64.deb
