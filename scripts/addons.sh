# NB This file should only be used for configuring a new box

echo "******************************************"
echo "************** ADDONS ********************"
echo "******************************************"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 1G/g' /etc/php/7.0/fpm/php.ini
touch  /home/vagrant/Code/nginx.conf

echo "** Installing Imagemagic php-imagick**";
sudo apt-get install imagemagick php-imagick -y

echo "** RESTARTING THINGS **"
service php7.0-fpm restart
service nginx restart

echo "** INSTALLING PHPUNIT **"
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit
sudo phpunit --version

echo "** INSTALLING YARN **"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install yarn -y

echo "** SPEEDING UP DB **"
sudo echo "innodb_flush_log_at_trx_commit = 2" >> /etc/mysql/my.cnf
sudo sed -i 's/skip-external-locking/skip-external-locking\ninnodb_flush_log_at_trx_commit = 2/g' /etc/mysql/my.cnf
sudo service mysql restart