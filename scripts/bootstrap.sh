#!/bin/sh

# installing node
sudo apt-get -y update
sudo apt-get -y install python-software-properties python g++ make curl ssh
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get -y update
sudo apt-get install -y nodejs

# install meteor
curl https://install.meteor.com/ | sh

# install meteorite
npm install -g meteorite

# update meteor
mrt install

