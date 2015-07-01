[![logo](http://www.linkideo.com/images/openvpn_logo.jpg)](https://openvpn.net/)

OpenVPN Access Server
==========================


OpenVPN - https://openvpn.net/index.php/access-server/overview.html



Running on the latest Phusion release (ubuntu 14.04), with OpenVPN AS 2.0.17.

**Pull image**

```
docker pull mace/openvpn-as
```

**Run container**

```
docker run -d --net="host" --privileged --name=<container name> -v <path for openvpn config files files>:/config -v /etc/localtime:/etc/localtime:ro -e ADMIN_PASS=<web ui password> -e VPN_USER1=<vpn username> -e VPN_PASS1=<vpn password> -e VPN_USER2=<vpn username> -e VPN_PASS2=<vpn password> mace/openvpn-as
```
Please replace all user variables in the above command defined by <> with the correct values.

**Web-UI**

```
http://<host ip>:943/admin
```

Username for the webui is "openvpn" and the admin-password from the run command.


**Example**

```
docker run -d --net="host" --cap-add=NET_ADMIN --device /dev/net/tun --name=openvpnas -v /mylocal/directory/fordata:/config -v /etc/localtime:/etc/localtime:ro -e ADMIN_PASS=mywebuiadminpass -e VPN_USER1=myuser1 -e VPN_PASS1=mypassword1 -e VPN_USER2=myuser2 -e VPN_PASS2=mypassword2 mace/openvpn-as
```

**Additional notes**


* The owner of the config directory needs sufficent permissions (UUID 99 / GID 100).
* Dont forget to forward/open ports to/on you docker host or in your router/firewall, the ports can be changed in the webui.
```
1194/udp 443/tcp  (943/tcp for webui if needed)
```
* Check the manual from the link on the top for how to setup the server.
* Vpn users1,2 needs to be added in the webui under "User Permissions" matching the exact name from the run command.
* This Docker uses host network to be able to reach resources from the local LAN.

