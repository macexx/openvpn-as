[![logo](http://www.linkideo.com/images/openvpn_logo.jpg)](https://openvpn.net/)

OpenVPN Access Server
==========================


OpenVPN - https://openvpn.net/index.php/access-server/overview.html



Running on the latest Phusion release (ubuntu 14.04), with OpenVPN AS 2.0.21.

**Pull image**

```
docker pull mace/openvpn-as
```

**Run container**

```
docker run -d --net="host" --privileged --name=<container name> -v <path for openvpn config files>:/config -v /etc/localtime:/etc/localtime:ro mace/openvpn-as
```
Please replace all user variables in the above command defined by <> with the correct values.
If you need to change the lisetning interface add(default is eth0):
```
-v INTERFACE=<interface name>
```

**Web-UI**

```
http://<host ip>:943/admin
```

Username for the webui is "admin" and the password is "openvpn".


**Example**

```
docker run -d --net="host"  --privileged --name=openvpnas -v /mylocal/directory/fordata:/config -v /etc/localtime:/etc/localtime:ro -e INTERFACE=br0 mace/openvpn-as
```

For use with "pipework" --  https://hub.docker.com/r/dreamcat4/pipework/
```
docker run -d --privileged --net=none --name=openvpnas -v /mylocal/directory/fordata:/config -v /etc/localtime:/etc/localtime:ro -e  PIPEWORK=yes -e 'pipework_cmd=br0 @openvpnas@ 192.168.1.10/24@192.168.1.1' mace/openvpn-as
```


**Additional notes**


* The owner of the config directory needs sufficent permissions (UUID 99 / GID 100).
* Dont forget to forward/open ports to/on you docker host or in your router/firewall, the ports can be changed in the webui.
```
1194/udp 9443/tcp  (943/tcp for webui if needed)
```
* Check the manual from the link on the top for how to setup the server.
* If "PIPEWORK" varable is set to "yes" dont use INTERFACE variable.
* When "PIPEWORK" varable is set dont forget to don´t use any network.


**Change notes**

Change notes

* 2015.07.01

Complete rewrite - Last code diden´t survive upgrades of openvpn and sometimes got corrupted on docker rebuilds. New code to better fit unRAID permissions and Phusion template. (Need to set a new config directory/ or clear old one- if upgrading).
* 2015.08.11

Update Phusion base-image, Update to Openvpn-AS 2.0.20.
* 2015.08.15

Admin username changed, "admin" and password "openvpn".
Default tcp port changed from 443 to 9443
All username/passvord variables removed, now uses internal database.
"INTERFACE" variable added, fixes bond0 issues.
openvpn is now running as nobody:users.
* 2015.10.7

Fix error that /mnt/user/(appdata) couldent be used. (symlinked and samba shares for non unRAID systems)
* 2015.10.17

Update to openvpn-as openvpn-as-2.0.21.
* 2015.11.12

Add variable for pipework, "PIPEWORK".
* 2015.08.11

Update Phusion base-image. 

[font size=4]2015.08.15[/font]
    - Admin username changed, "admin" and password "openvpn".
    - Default tcp port changed from 443 to 9443.
    - All username/passvord variables removed, now uses internal database.
    - "INTERFACE" variable added, fixes bond0 issues.
    - openvpn is now running as nobody:users.

    [font size=4]2015.10.7[/font]
    - Fix error that /mnt/user/(appdata) couldent be used.

    [font size=4]2015.10.17[/font]
    - Update to openvpn-as openvpn-as-2.0.21

    [font size=4]2015.11.12[/font]
    - Added support for pipework (defaults to eth1 and port 443 instead of 9443)

    [font size=4]2015.12.16[/font]
    - Upgrade Phusion base-image.

    [font size=4]2015.12.19[/font]
    - Revert to previous Phusion base-image.(New image is bugged)

    [font size=4]2015.12.24[/font]
    - Phusion base-image.(Upgrade sys-log)
    - Add apt-get upgrade for security updates should have been enabled along time ago

    [font size=4]2016.01.06[/font]
    - Upgrade to Openvpn-as-2.0.24 

    [font size=4]2016.03.24[/font]
    - Upgrade to Openvpn-as-2.0.25
