#!/usr/bin/env bash

set -x
export DEBIAN_FRONTEND=noninteractive

if [ ! -e "/home/vagrant/.firstboot" ]; then
  dpkg --purge ufw
  apt-get update
  apt-get install -y --force-yes vim curl unzip software-properties-common python-software-properties
  add-apt-repository ppa:webupd8team/java
  apt-get update
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
  apt-get install -y --force-yes oracle-java7-installer

  # install play 2.1.3
  cd /opt
  wget http://downloads.typesafe.com/play/2.1.3/play-2.1.3.zip 
  unzip play-2.1.3.zip
  ln -s /opt/play-2.1.3/play /usr/bin/play  
  chown -R vagrant:vagrant /opt/play-2.1.3

  touch /home/vagrant/.firstboot

  reboot
fi

