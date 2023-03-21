#!/bin/bash

sudo apt-get install nginx
sudo apt-get install gunicorn
path=~/web/
mkdir -p ${path}{public/{img,css,js},uploads,etc}

if [ ! -e "${path}etc/nginx.conf" ]
then
    cat << "EOF" >> ${path}etc/nginx.conf
server {
    listen 80 default_server;
    error_log /var/log/nginx/test.log info;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    location ^~ /hello/ {
        proxy_pass https://0.0.0.0:8080;
    }
}
EOF
else
    echo "The file ${path}etc/nginx.conf already exists"
    cat ${path}etc/nginx.conf
fi

if [ ! -e "${path}etc/hello.py" ]
then
    cat << "EOF" >> ${path}etc/hello.py
bind = "0.0.0.0:8080"

def app(environ, start_response):
    data = (bytes(i, encoding="utf-8") for i in environ['QUERY_STRING'].split("&"))
    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]
    start_response(status, response_headers)
    return data
EOF
else
    echo "The file ${path}etc/hello.py already exists"
    cat ${path}etc/hello.py
fi
sudo ln -sf ${path}etc/nginx.conf /etc/nginx/sites-enabled/default
sudo /etc/init.d/nginx restart
cd ${path}/web/etc && gunicorn -c python:hello hello:app &
