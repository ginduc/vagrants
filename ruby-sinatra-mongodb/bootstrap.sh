#!/usr/bin/env bash

# use apt-cacher-ng proxy on host (default Vbox NAT ip 10.0.2.2)
# Add line "PfilePattern = .*" to /etc/apt-cacher-ng/acng.conf
# HTTP_PROXY=http://10.0.2.2:3142

set -x
export DEBIAN_FRONTEND=noninteractive

if [ ! -e "/home/vagrant/.firstboot" ]; then
  # update us. -> ph. in apt sources.list to use APT server from Finland
  perl -i -p -e 's/\/\/us\./\/\/ph./g' /etc/apt/sources.list

  # install mongodb repo
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
  
  # remove ufw firewall
  dpkg --purge ufw
  apt-get update
 
  # install required packages
  apt-get install -y --force-yes vim curl unzip software-properties-common python-software-properties

  # install ruby dev env
  curl -L https://get.rvm.io | bash -s stable --ruby
  echo "gem: --no-ri --no-rdoc" > /etc/gemrc
  gem install bundler sinatra shotgun rack mongodb mongo bson_ext 
  usermod -a -G rvm vagrant

  # install mongodb
  apt-get install mongodb-10gen
  echo "mongodb-10gen hold" | dpkg --set-selections
  service mongodb start
  mkdir -p /data/db/
  chown vagrant /data/db

  # config local datetime
  mv /etc/localtime /etc/localtime.bak
  ln -s /usr/share/zoneinfo/Asia/Manila /etc/localtime
  dpkg-reconfigure --frontend noninteractive tzdata

  touch /home/vagrant/.firstboot
  reboot
fi

