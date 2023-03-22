#!/bin/bash

sudo apt-get install nginx
path=~/web/
mkdir -p ${path}{public/{img,css,js},uploads,etc}

if [ ! -e "${path}etc/nginx.conf" ]
then
    cat << EOF >> ${path}etc/nginx.conf
server {
    listen 80;
    error_log /var/log/nginx/test.log info;

    location ^~ /uploads/ {
        root ${path};
    }

    location ~* ^.+\.\w+$ {
        root ${path}public;
    }

    location / {
        return 404;
    }
}
EOF
else
    echo "The file ${path}etc/nginx.conf already exists"
    cat ${path}etc/nginx.conf
fi
sudo ln -sf ${path}etc/nginx.conf /etc/nginx/sites-enabled/default
sudo /etc/init.d/nginx restart