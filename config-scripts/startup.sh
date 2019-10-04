#!/bin/bash
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list'
sudo apt update
sudo apt install -y mongodb-org
systemctl enable mongod.service
systemctl start mongod.service
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d

