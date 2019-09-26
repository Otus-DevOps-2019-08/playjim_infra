# playjim_infra
playjim Infra repository by Dmitry Borisov
## Table of contents	
- [HW2. ChatOps](#HW2.ChaOps.)
	- [GIT](#GIT.)
- [HW3. GCP: Bastion Host, Pritunl VPN.](#HW3.GCP:Bastion Host,PritunlVPN.)
	- [Bastion-host](#Bastion-host)
	- [VPN](VPN)

# HW 2.ChatOps.
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/1/files

## GIT.

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

# HW3. GCP: Bastion Host, Pritunl VPN.


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
