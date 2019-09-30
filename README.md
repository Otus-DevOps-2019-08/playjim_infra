# playjim_infra
playjim Infra repository by Dmitry Borisov
## Table of contents	
- [HW2. ChatOps](#HW2-ChatOps)
	- [GIT](#GIT)
- [HW3. GCP: Bastion Host, Pritunl VPN](#HW3-GCP-Bastion-Host-Pritunl-VPN)
	- [Bastion-host](#Bastion-host)
	- [VPN](#VPN)
- [HM4. GCP: Deploy test app, gcloud, ruby, MongoDB](#HM4-GCP-Deploy-test-app-gcloud-ruby-MongoDB)
	- [gcloud](#gcloud)
	- [ruby](#ruby)
	- [MongoDB](#MongoDB)
	- [Deploy test app](#Deploy-test-app)
	- [Bash script](#Bash-script)
	- [gcloud firewall](#gcloud-firewall)
# HW2. ChatOps
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/1/files

## GIT

git-clone - Clone a repository into a new directory
```sh
$ git clone git@github.com:Otus-DevOps-2019-08/playjim_infra.git
```
git-checkout - Switch branches or restore working tree files
```sh
$ git checkout -b play-travis
$ git checkout -- README.md
```
add; commit; push;
```sh
git add PULL_REQUEST_TEMPLATE.md
git commit -m 'Add PR template'
git push --set-upstream origin play-travis
```

# HW3. GCP: Bastion Host, Pritunl VPN
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/2/files

## Bastion-host
bastion_IP = 34.89.223.37
someinternalhost_IP = 10.156.0.11

SSH Forwarding:
```sh
$ ssh-add -L
```
Key:
```sh
$ ssh-add ~/.ssh/d.borisov
```
SSH Connection:
```sh
$ ssh -i ~/.ssh/d.borisov -A playjim@34.89.223.37
$ ssh 10.156.0.11
```
Для подключения одной строкой к someinternalhost использовал :
```sh
$ ssh -i ~/.ssh/d.borisov -A playjim@34.89.223.37 -tt ssh 10.156.0.11
```
Для подключения к someinternalhost таким образом - ssh someinternalhost - настроил .ssh/config:
```sh
Host bastion
  Hostname 34.89.223.37
  User playjim
  IdentityFile ~/.ssh/d.borisov

Host someinternalhost
  Hostname 10.156.0.11
  User playjim
  ProxyCommand ssh -W %h:%p bastion
  IdentityFile ~/.ssh/d.borisov
``` 

## VPN
 - Файл setupvpn.sh описывает установку VPN-сервера, устанавливает mongod и pritunl
 - Файл cloud-bastion.ovpn - конф файл для настройки OpenVPN клиента

# HM4. GCP: Deploy test app, gcloud, ruby, MongoDB
PR: 
GitHub gist: https://gist.github.com/Nklya/b6d1a547415b123f6b0cd0e90d208bf8

## gcloud
testapp_IP = 34.89.223.37
testapp_port = 9292

Для создания инстанса через gcloud использовал шаблон:
```sh
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
```

## ruby
Установка Ruby и Bundler:
```sh
$ sudo apt install -y ruby-full ruby-bundler build-essential
```

## MongoDB
Install MongoDB for ubuntu 16.04:

add the key:
	```sh
	$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
	```
Now, create a new MongoDB repository list file:
	```sh
	$ sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list'
	```
Complete the installation with update of repositories then install:
	```sh
	$ sudo apt update
	$ sudo apt install mongodb-org
	```
Enable the mongod service and start it up:
	```sh
	$ systemctl enable mongod.service
	$ systemctl start mongod.service
	```
Check your mongodb version:
	```sh
	$ mongo --version
	```
Check if the service is running:

	```sh
	$ systemctl status mongod.service
	```

## Deploy test app
Go to the home directory and copy the application code:
```sh
$ cd ~
$ git clone -b monolith https://github.com/express42/reddit.git
```
Go to the directory of project and install Go to the directory of project and install:
```sh
$ cd reddit && bundle install
```
Start the application server in the project directory:
```sh
$ puma -d
```
Checkout status serverCheckout status server:
```sh
$ ps aux | grep puma
playjim  19187  0.0  1.8 652624 32204 ?        Sl   18:49   0:03 puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]
playjim  20776  0.0  0.0  12944   904 pts/0    S+   21:08   0:00 grep --color=auto puma
```

## Bash script
install_ruby.sh
```sh
#!/bin/bash
#First line ia a directory bash
#This is a comment
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential
```
install_mongodb.sh
```sh
#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list'
sudo apt update
sudo apt install -y mongodb-org
systemctl enable mongod.service
systemctl start mongod.service
```
deploy.sh
```sh
#!/bin/bash
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
ps aux | grep puma
```
Объеденил эти скрипты в один и назвал его startup.sh. Содержание скрипта:
```sh
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
```
Создал storage GCP playjim-bucket.
Скопировал startup.sh в Storage:
```sh
$ gsutil cp startup.sh gs://playjim-bucket/ 
Copying file://startup.sh [Content-Type=text/x-sh]...
- [1 files][  519.0 B/  519.0 B]                                                
Operation completed over 1 objects/519.0 B.              
```
Создание инстанса с применением startup скрипта:
```sh
gcloud compute instances create test-startup\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script='gsutil cp gs://playjim-bucket/startup.sh startup.sh;chmod +x startup.sh;./startup.sh'
```

## gcloud firewall
Открытие порта через gcloud:
```sh
gcloud compute firewall-rules create default-puma-server\
  --network default\
  --action allow\
  --direction ingress\
  --rules tcp:9292\
  --priority 1000\
  --target-tags puma-server
```
