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



# Config
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash

# Set log directory

mkdir -p /config/logs
touch /config/logs/openvpnas.log

# Checking if openvpn configuration exists

if [ -d "/config/config/etc" ]; then
  echo "Config exists, importing previous configuration!"
  rm -r /usr/local/openvpn_as/etc
  rm /var/log/openvpnas.log
  ln -sf /config/config/etc /usr/local/openvpn_as/etc
  ln -sf /config/logs/openvpnas.log /var/log/openvpnas.log
else
  echo "Copying configuration from install directory to host!"
  mkdir -p /config/config
  mv /usr/local/openvpn_as/etc /config/config/etc
  rm /var/log/openvpnas.log
  ln -sf /config/config/etc /usr/local/openvpn_as/etc
  ln -sf /config/logs/openvpnas.log /var/log/openvpnas.log
fi

# Setting default values for config files

check=$( grep -ic "nobody" /config/config/etc/as.conf )
check2=$( grep -ic "/tmp/sock" /config/config/etc/as.conf )

if [[ $check -gt 1 && $check2 -gt 1 ]]; then
  echo "Checking configuration, Defaults are already set!"
else
  echo "Checking configuration, Setting Openvpn-AS defaults or update is beeing made!"
  sed -i 's/^boot_pam_service=openvpnas.*/boot_pam_service=nobody/' /config/config/etc/as.conf
  sed -i 's/^boot_pam_users.0=openvpn.*/#boot_pam_users.0=openvpn/' /config/config/etc/as.conf
  sed -i 's/^system_users_local.1=openvpn_as.*/system_users_local.1=nobody/' /config/config/etc/as.conf
  sed -i 's/^cs.user=openvpn_as.*/cs.user=nobody/' /config/config/etc/as.conf
  sed -i 's/^cs.group=openvpn_as.*/cs.group=users/' /config/config/etc/as.conf
  sed -i 's/^vpn.server.user=openvpn_as.*/vpn.server.user=nobody/' /config/config/etc/as.conf
  sed -i 's/^vpn.server.group=openvpn_as.*/vpn.server.group=users/' /config/config/etc/as.conf
  sed -i 's|^general.sock_dir=~/sock.*|general.sock_dir=/tmp/sock|' /config/config/etc/as.conf
  sed -i 's|^sa.sock=~/sock/sagent.*|sa.sock=/tmp/sock/sagent|' /config/config/etc/as.conf
  /usr/local/openvpn_as/scripts/confdba -mk "auth.module.type" -v "local"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.listen.port" -v "9443"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.server.daemon.tcp.port" -v "9443"
fi

# Setting listening network interface, defaults to eth0 if INTERFACE or PIPEWORK variable isent set.

if [ -v "INTERFACE" ]; then
  echo "Setting listening Interface to Interface, $INTERFACE!!"
  /usr/local/openvpn_as/scripts/confdba -mk "admin_ui.https.ip_address" -v "$INTERFACE"
  /usr/local/openvpn_as/scripts/confdba -mk "cs.https.ip_address" -v "$INTERFACE"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.listen.ip_address" -v "$INTERFACE"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.server.ip_address" -v "$INTERFACE"
elif [ -v "PIPEWORK" ]; then
  echo "Pipework is enabled, Setting interface to "eth1" and changing https port to default "443"!"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.listen.port" -v "443"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.server.daemon.tcp.port" -v "443"
  /usr/local/openvpn_as/scripts/confdba -mk "admin_ui.https.ip_address" -v "eth1"
  /usr/local/openvpn_as/scripts/confdba -mk "cs.https.ip_address" -v "eth1"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.listen.ip_address" -v "eth1"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.server.ip_address" -v "eth1"
else
  echo "Interface variable is not set, Defaulting to interface "eth0"!"
  /usr/local/openvpn_as/scripts/confdba -mk "admin_ui.https.ip_address" -v "eth0"
  /usr/local/openvpn_as/scripts/confdba -mk "cs.https.ip_address" -v "eth0"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.listen.ip_address" -v "eth0"
  /usr/local/openvpn_as/scripts/confdba -mk "vpn.daemon.0.server.ip_address" -v "eth0"
fi

# Setting up socks directory for openvpn-as(prevents host permissions to "bug")
if [ ! -d "/tmp/sock" ]; then
mkdir -p /tmp/sock
chown nobody:users /tmp/sock
chmod 777 /tmp/sock
fi

# Setting permissions so that host can edit config
chown -R nobody:users /config
chmod 777 /config/logs/openvpnas.log	
EOT

# Start openvpn and check admin user
cat <<'EOT' > /etc/my_init.d/01_start.sh
#!/bin/bash

# Checking if default admin user is set
user=$( /usr/local/openvpn_as/scripts/confdba -us|grep -ic "admin" )

if [ -v "PIPEWORK" ]; then
  echo "Pipework is enabled waiting for network to come up..."
  pipework --wait
fi

echo "Upgrading local packages(Security) - This might take awhile(first run takes some extra time)"
apt-get update -qq && apt-get upgrade -yqq
echo "Upgrade Done...."

if [ $user -eq 1 ]; then
  echo "Admin username and password has already been set! Starting Openvpn-AS."
  /etc/init.d/openvpnas start
else
  /etc/init.d/openvpnas start
  echo "Setting Admin default username and password: admin/openvpn"
  sleep 2
  /usr/local/openvpn_as/scripts/sacli -u admin -k prop_superuser -v true UserPropPut
  /usr/local/openvpn_as/scripts/sacli -u admin --new_pass openvpn SetLocalPassword
  /usr/local/openvpn_as/scripts/sacli -u openvpn UserPropDelAll
  /etc/init.d/openvpnas restart
fi
EOT

chmod -R +x /etc/my_init.d/


#########################################
##             INTALLATION             ##
#########################################

# Download pipework
bash -c "curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/local/bin/pipework"
chmod +x /usr/local/bin/pipework

# Install OpenVPN-AS
curl -O http://swupdate.openvpn.org/as/openvpn-as-2.1.1-Ubuntu14.amd_64.deb
dpkg -i openvpn-as-2.1.1-Ubuntu14.amd_64.deb 



#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
rm openvpn-as-2.1.1-Ubuntu14.amd_64.deb 
