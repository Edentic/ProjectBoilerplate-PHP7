echo "*** INSTALLING JAVA ***"
sudo apt-get update
sudo apt-get install default-jre -y

echo "*** INSTALLING VIRTUAL DESKTOP ***"
sudo apt-get install xvfb -y
(crontab -u vagrant -l; echo "@reboot sh -c 'Xvfb :99 -ac -screen 0 1024x768x8 > /tmp/xvfb.log 2>&1 &'" ) | crontab -u vagrant -
sudo Xvfb :99 -ac -screen 0 1024x768x8 > /tmp/xvfb.log 2>&1 &

echo "*** INSTALLING VNC SERVER ***"
sudo apt-get install x11vnc -y

echo "*** INSTALLING SELENIUM ***"
service=$(cat <<"EOF"
#!/bin/bash
case "${1:-''}" in
    'start')
        if test -f /tmp/selenium.pid
        then
            echo "Selenium is already running."
        else
            export DISPLAY=localhost:99.0
            selenium-standalone start > /var/log/selenium/output.log 2> /var/log/selenium/error.log & echo $! > /tmp/selenium.pid
            echo "Starting Selenium..."

            error=$?
            if test $error -gt 0
            then
                echo "${bon}Error $error! Couldn't start Selenium!${boff}"
            fi
        fi
    ;;
    'stop')
        if test -f /tmp/selenium.pid
        then
            echo "Stopping Selenium..."
            PID=`cat /tmp/selenium.pid`
            kill -3 $PID
            if kill -9 $PID ;
                then
                    sleep 2
                    test -f /tmp/selenium.pid && rm -f /tmp/selenium.pid
                else
                    echo "Selenium could not be stopped..."
                fi
        else
            echo "Selenium is not running."
        fi
        ;;
    'restart')
        if test -f /tmp/selenium.pid
        then
            kill -HUP `cat /tmp/selenium.pid`
            test -f /tmp/selenium.pid && rm -f /tmp/selenium.pid
            sleep 1
            export DISPLAY=localhost:99.0
            selenium-standalone start > /var/log/selenium/output.log 2> /var/log/selenium/error.log & echo $! > /tmp/selenium.pid
            echo "Reload Selenium..."
        else
            echo "Selenium isn't running..."
        fi
        ;;
    *)      # no parameter specified
        echo "Usage: $SELF start|stop|restart"
        exit 1
    ;;
esac
EOF
)

sudo npm install selenium-standalone@4.7.2 -g
sudo selenium-standalone install
sudo echo "$service" > /etc/init.d/selenium
sudo chmod 755 /etc/init.d/selenium
sudo mkdir -p /var/log/selenium
sudo chmod a+w /var/log/selenium
sudo update-rc.d selenium defaults

echo "*** INSTALLING GOOGLE CHROME ***"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install google-chrome-stable -y

echo "*** STARTING SELENIUM SERVICE ***"
sudo service selenium start

echo "*** SETTING UP TESTING ENV ***"
block="server {
    listen 1337;
    server_name 192.168.*;
    root \"/home/vagrant/Code/public\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/test-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;

        fastcgi_param APP_ENV testing;
        fastcgi_param DB_DATABASE bmrk_datingsystem_test;
        fastcgi_param MEDIA_FOLDER media_test;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

echo "$block" > "/etc/nginx/sites-available/192.168.*_test"
ln -fs "/etc/nginx/sites-available/192.168.*_test" "/etc/nginx/sites-enabled/192.168.*_test"
service nginx restart
service php7.0-fpm restart