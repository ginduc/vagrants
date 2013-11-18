#!/usr/bin/env bash

set -x
export DEBIAN_FRONTEND=noninteractive

if [ ! -e "/home/vagrant/.firstboot" ]; then
  # update us. -> ph. in apt sources.list to use APT server from PH
  perl -i -p -e 's/\/\/us\./\/\/ph./g' /etc/apt/sources.list

  # remove ufw firewall
  dpkg --purge ufw
  apt-get update
 
  # install required packages
  apt-get install -y --force-yes git vim curl unzip software-properties-common python-software-properties libmysql-ruby libmysqlclient-dev

  # install mysql
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password password'
  sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password password'
  apt-get install -y mysql-server-5.5 

  if [ ! -f /var/log/db_setup ];
  then
    export mydb="devdb"
    export myuser="webapp"
    export mypw="1234"
    mysql -uroot -ppassword -e "create database $mydb;"
    mysql -uroot -ppassword -e "create user '$myuser'@'%' identified by '$mypw';"
    mysql -uroot -ppassword -e "create user '$myuser'@'localhost' identified by '$mypw';"
    mysql -uroot -ppassword -e "grant all privileges on $mydb.* to '$myuser'@'%' with grant option; flush privileges;"
    mysql -uroot -ppassword -e "grant all privileges on $mydb.* to '$myuser'@'localhost' with grant option; flush privileges;"

    cp /vagrant/my.cnf.template /etc/mysql/my.cnf
    touch /var/log/db_setup
  fi 

  # install ruby dev env
  curl -L https://get.rvm.io | bash -s stable --ruby
  source /usr/local/rvm/scripts/rvm
  echo "gem: --no-ri --no-rdoc" > /etc/gemrc
  gem install bundler rails execjs rspec-rails cucumber-rails database_cleaner rack mongodb mongo bson bson_ext mysql2
  usermod -a -G rvm vagrant

  mkdir /home/vagrant/.vim
  unzip /vagrant/vimrails.zip -d /home/vagrant/.vim
  chown -R vagrant:vagrant /home/vagrant/.vim

  # config local datetime
  mv /etc/localtime /etc/localtime.bak
  ln -s /usr/share/zoneinfo/Asia/Manila /etc/localtime

  touch /home/vagrant/.firstboot
  reboot
fi

