#!/bin/bash
apt-get update 
echo "Asia/Singapore" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
# Enable Ubuntu Firewall
#ufw --force enable
#Allow SSH & MySQL Ports
#ufw --force allow 22
#ufw --force allow 3306
# Install MySQL Server in a Non-Interactive mode.
echo "mysql-server-5.7 mysql-server/root_password password J4BB3rW0cky##" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password J4BB3rW0cky##" | sudo debconf-set-selections
apt-get -y install mysql-server-5.7
mysql_secure_installation <<EOF
y
secret
secret
y
y
y
y
EOF
#Allow mysql db to be available on all interfaces
sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
#Allow network connections to db
mysql -uroot -pJ4BB3rW0cky## -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES; CREATE database crud;'

#restart mysql to effect network listen changes
systemctl restart mysql
