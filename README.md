[![logo](http://www.linkideo.com/images/openvpn_logo.jpg)](https://openvpn.net/)

OpenVPN Access Server
==========================


OpenVPN - https://openvpn.net/index.php/access-server/overview.html



Running on the latest Phusion release (ubuntu 14.04), with OpenVPN AS 2.0.20.

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

* Ass variable for pipework, "PIPEWORK".
* Fix error that some host paths/permissions prevents openvpn to run
* Admin username changed, "admin" and password "openvpn".
* Default deamon tcp port changed from 443 to 9443.
* All username and passvord variables was removed, now uses openvpn-as´s internal database.
* "INTERFACE" variable added so that webui is reachable if eth0 isent linked to docker.(Defaults to eth0 if variable isent set in the run command)
* Now run as nobody:users
