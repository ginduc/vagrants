#!/usr/bin/env bash

set -x

if [ ! -e "/home/vagrant/.firstboot" ]; then
  # Docker
  # rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  yum -y install docker-io
  service docker start
  chkconfig docker on

  # Git
  yum -y install git wget

  # Local time
  mv /etc/localtime /etc/localtime.bak
  ln -s /usr/share/zoneinfo/Asia/Manila /etc/localtime

  touch /home/vagrant/.firstboot
fi

