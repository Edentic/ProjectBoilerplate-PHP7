#!/bin/bash
cd /home/vagrant/Code
if [ -e ./artisan ]
then
    composer install
    php artisan key:generate
else
    composer create-project --prefer-dist laravel/laravel /home/vagrant/laravel_install
    rm -rf /home/vagrant/laravel_install/.git
    cp -nr /home/vagrant/laravel_install/.* ./
    cp -nr /home/vagrant/laravel_install/* ./
    rm -r /home/vagrant/laravel_install/
    rm -rf ./Code
    rm -rf ./local
    rm -rf ./ssh
    rm  -f ./.bashrc
    rm  -f ./.hhvm.hhbc
    rm  -f ./.profile
    rm  -f ./vbox_version
fi