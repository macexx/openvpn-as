# Builds a docker image for a OpenVPN Access Server
FROM phusion/baseimage:0.9.22
MAINTAINER Mace Capri <macecapri@gmail.com>


###############################################
##           ENVIRONMENTAL CONFIG            ##
###############################################
# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

###############################################
##   INTALL ENVIORMENT, INSTALL OPENVPN      ##
###############################################
COPY install.sh /tmp/
RUN chmod +x /tmp/install.sh && sleep 1 && /tmp/install.sh && rm /tmp/install.sh


###############################################
##             PORTS AND VOLUMES             ##
###############################################

#expose 9443/tcp
#expose 443/tcp
#expose 943/tcp
#expose 1194/udp
VOLUME /config
