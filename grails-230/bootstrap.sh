#!/usr/bin/env bash

set -x
export DEBIAN_FRONTEND=noninteractive

  dpkg --purge ufw
  apt-get update
  apt-get install -y --force-yes vim curl unzip software-properties-common python-software-properties

  # install mysql
  export myrootpw="root"
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password $myrootpw'
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password $myrootpw'
  apt-get install -y mysql-server-5.5 

  # java 7
  add-apt-repository ppa:webupd8team/java
  apt-get update
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
  apt-get install -y --force-yes oracle-java7-installer

  # Install GVM & Grails
  su -l -c "curl -s get.gvmtool.net | bash" vagrant
  su -l -c "perl -i -p -e 's/gvm_auto_answer=false/gvm_auto_answer=true/' ~/.gvm/etc/config" vagrant  
  su -l -c "gvm install grails" vagrant
  
  touch /home/vagrant/.firstboot


  if [ ! -f /var/log/db_setup ];
  then
    export mydb="mydb"
    export myuser="myuser"
    export mypw="mypw"
    mysql -uroot -proot -e "create database $mydb;"
    mysql -uroot -proot -e "create user '$myuser'@'%' identified by '$mypw';"
    mysql -uroot -proot -e "create user '$myuser'@'localhost' identified by '$mypw';"
    mysql -uroot -proot -e "grant all privileges on $mydb.* to '$myuser'@'%' with grant option; flush privileges;"
    mysql -uroot -proot -e "grant all privileges on $mydb.* to '$myuser'@'localhost' with grant option; flush privileges;"

    cp /vagrant/my.cnf.template /etc/mysql/my.cnf
    touch /var/log/db_setup
  fi

  reboot
fi

