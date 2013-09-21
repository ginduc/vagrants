#!/usr/bin/env bash

set -x
export DEBIAN_FRONTEND=noninteractive

  dpkg --purge ufw
  apt-get update
  apt-get install -y --force-yes vim curl unzip software-properties-common python-software-properties apache2 php5 php5-mysql

  # install mysql
  export myrootpw="myrootpw"
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password $myrootpw'
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password $myrootpw'
  apt-get install -y mysql-server-5.5 

  if [ ! -f /var/log/db_setup ];
  then
    export mydb = "mydb"
    export myuser = "myuser"
    export mypw = "mypw"
    mysql -uroot -p$myrootpw -e "create database $mydb;"
    mysql -uroot -p$myrootpw -e "create user '$myuser'@'%' identified by '$mypw';"
    mysql -uroot -p$myrootpw -e "create user '$myuser'@'localhost' identified by '$mypw';"
    mysql -uroot -p$myrootpw -e "grant all privileges on $mydb.* to '$myuser'@'%' with grant option; flush privileges;"
    mysql -uroot -p$myrootpw -e "grant all privileges on $mydb.* to '$myuser'@'localhost' with grant option; flush privileges;"

    cp /vagrant/my.cnf.template /etc/mysql/my.cnf
    touch /var/log/db_setup

    if [ -f /vagrant/initialdb.sql ];
    then
        mysql -uroot -p$myrootpw $mydb < /vagrant/initialdb.sql
    fi
  fi
 
  cd /var
  wget http://wordpress.org/latest.tar.gz
  tar -xvf latest.tar.gz 
  rm -rf www && mv wordpress www 
  cp /vagrant/wp-config.php.template /var/www/wp-config.php

  service apache2 restart
  touch /home/vagrant/.firstboot
  reboot
fi

