#!/bin/bash

#Refresh package list
apt-get -y update

# Install Node.js and app dependencies
apt-get -y install build-essential git
command -v npm > /dev/null
if [ $? -ne 0 ]; then
	mkdir /tmp/nodejs-install
	cd /tmp/nodejs-install
	curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
	./configure
	make install
	curl https://npmjs.org/install.sh | clean=no sh
fi
cd /vagrant
npm install
npm install -g grunt-cli coffee-script bower

# Install supervisor, which runs Grunt
mkdir -p /etc/supervisor/conf.d
cp /vagrant/development/grunt.conf /etc/supervisor/conf.d
apt-get -y install supervisor
rm -f /etc/init.d/supervisor
cp /vagrant/development/supervisor.conf /etc/init/supervisor.conf
stop supervisor
sleep 3
start supervisor

# Install Nginx and configure it to serve /vagrant/public
apt-get install -y nginx
cp /vagrant/development/default /etc/nginx/sites-available/
service nginx restart



