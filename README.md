# playjim_infra
playjim Infra repository by Dmitry Borisov
## Table of contents	
- [HW2. ChatOps](#HW2-ChaOps)
	- [GIT](#GIT)
- [HW3. GCP: Bastion Host, Pritunl VPN](#HW3-GCP-Bastion-Host-Pritunl-VPN)
	- [Bastion-host](#Bastion-host)
	- [VPN](#VPN)
- [HM4. GCP: Deploy test app, gcloud, ruby, MongoDB](#HM4-GCP-Deploy-test-app-gcloud-ruby-MongoDB)
	- [gcloud](#gcloud)
	- [ruby](#ruby)
	- [MongoDB](#MongoDB)
	- [Deploy test app](#Deploy-test-app)
	- [Bash script](#Bashs-cript)
	- [gcloud firewall](#gcloud-firewall)
- [HW5. GCP: Build an Image, Packer](#HW5-GCP-Build-an-Image-Packer)
	- [Packer](#Packer)
	- [ADC](#ADC)
	- [Доп. задание](#Доп-задание)
- [HW6. Terraform-1](#HW6-Terraform-1)
	- [Input vars](#Input-vars)
	- [Output vars](#Output-vars)
	- [The final test](#The-final-test)
	- [Самостоятельная работа](#Самостоятельная-работа)
	- [Доп. задание](#Доп-задание)
- [HW7. Terraform-2](#HW7-Terraform-2)
	- [Самостоятельное задание](#Самостоятельное-задание)
	- [Модуль storage-bucket](#Модуль-storage-bucket)
	
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

Сначало нужно запустить ssh-agent:
```sh
$ eval `ssh-agent -s`
Agent pid 2793
```
SSH Forwarding:
```sh
$ ssh-add -L
```
Key:
```sh
$ ssh-add ~/.ssh/appuser
```
SSH Connection:
```sh
$ ssh -i ~/.ssh/appuser -A playjim@34.89.223.37
$ ssh 10.156.0.11
```
Для подключения одной строкой к someinternalhost использовал :
```sh
$ ssh -i ~/.ssh/appuser -A playjim@34.89.223.37 -tt ssh 10.156.0.11
```
Для подключения к someinternalhost таким образом - ssh someinternalhost - настроил .ssh/config:
```sh
Host bastion
  Hostname 34.89.223.37
  User playjim
  IdentityFile ~/.ssh/appuser

Host someinternalhost
  Hostname 10.156.0.11
  User playjim
  ProxyCommand ssh -W %h:%p bastion
  IdentityFile ~/.ssh/appuser
```

## VPN
 - Файл setupvpn.sh описывает установку VPN-сервера, устанавливает mongod и pritunl
 - Файл cloud-bastion.ovpn - конф файл для настройки OpenVPN клиента

# HM4. GCP: Deploy test app, gcloud, ruby, MongoDB
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/3/files
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
	​```sh
	$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
	​```
Now, create a new MongoDB repository list file:
	​```sh
	$ sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list'
	​```
Complete the installation with update of repositories then install:
	​```sh
	$ sudo apt update
	$ sudo apt install mongodb-org
	​```
Enable the mongod service and start it up:
	​```sh
	$ systemctl enable mongod.service
	$ systemctl start mongod.service
	​```
Check your mongodb version:
	​```sh
	$ mongo --version
	​```
Check if the service is running:

	​```sh
	$ systemctl status mongod.service
	​```

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

# HW5. GCP: Build an Image, packer
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/4/files

## Packer
Скачал и распоковал архив packer. Поместил содержимое в /usr/sbin/.
```sh
$ packer -v
1.4.4
```

## ADC
Application Default Credentials
Для создания ADC:
```sh
$ gcloud auth application-default login
```

В директорию confg-scripts/ перенесены файлы:
deploy.sh
install_mongodb.sh
install_ruby.sh
startup.sh

Packer шаблон, с помощью которого собираем *baked-образ* с предустановленными Ruby и MongoDB - packer/ubuntu16.json  
В секции **builders** описано создание ВМ для билда и создание имиджа.  
В секции **provisioners** описана установка ПО, настройка системы и конфигурация приложений.  
В секции **variables** описаны пользовательские переменные.

В каталог packer/scripts/ (указан в provisioners) скопированы скрипты установки mongodb и ruby:  
install_mongodb.sh  
install_ruby.sh  

Валидация шаблона и построение образа ВМ:
```sh 
$ packer validate -var-file variables.json ubuntu16.json
Template validated successfully.
$ packer build -var-file variables.json ubuntu16.json
```

Устанавливаем инстанс из собранного образа.
Установка и запуск приложения:
```sh
$ ssh playjim@34.76.161.61
$ cd ~
$ gsutil cp gs://playjim-bucket/deploy.sh ~/
$ sudo chmod +x deploy.sh
$ ./deploy.sh
```
В файл *packer/variables.json* заданы обязательные переменные и файл добавлен в .gitignore до его индексации.

## Доп. задание 
"Запекаем" (bake) в образ VM все зависимости приложения и сам код приложения:
 - За основу шаблона взял **ubuntu16.json**. Внёс изменения в "image_family": "reddit-full"
 - В файле packer/files/deploy.sh описана установка приложения, создание systemd unit и запуск приложения.
 - Запуск постройки образа:  
 ```sh
 packer build -var-file variables.json immutable.json
 ```
 - Создание ВМ из подготовленного образа из семейства reddit-full (скрипт лежит в файле config-scripts/create-reddit-vm.sh):  
 ```sh
!#!/bin/bash
gcloud compute instances create reddit-app-full\
  --image-family reddit-full\
  --tags puma-server\
  --restart-on-failure
 ```

# HW6. Terraform-1
PR: https://github.com/Otus-DevOps-2019-08/playjim_infra/pull/6

 - Удалил ключ ползователя appuser из GCP  
 - Скачал terraform, распоковал и поместил в /usr/sbin
```sh
$ terraform -v
Terraform v0.12.10
```
 **main.tf** - главный конфигурационный файл, содержит декларативное описание нашей инфраструктуры.

 - Поместил в **.gitignore**:
```sh
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```

 - Определил секцию Provider в файле **main.tf**:
```sh
terraform {
  # Версия terraform
  required_version = "0.12.10"
}

provider "google" {
  # Версия провайдера
  version = "2.15"

  # ID проекта
  project = "infra-254011"

  region = "europe-west-1"
}
```
 - Выполнил инициализацию для загрузки модуля провайдера:
```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "google" (hashicorp/google) 2.15.0...

Terraform has been successfully initialized!
```
Terraform предоставляет широкий набор примитивов (resources)
для управления ресурсами различных сервисов GCP.

Полный список предоставляемых terraform'ом ресурсов для
работы с GCP можно посмотреть слева на https://www.terraform.io/docs/providers/google/index.html

 - В main.tf добавил ресурс для создания инстанса VM в GCP:
```sh
resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "g1-small"
  zone = "europe-west1-b"
  #определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }
}
```
 - Предварительно посмотрел какие изменения terraform собирается произвести:
```sh
$ terraform plan
Plan: 1 to add, 0 to change, 0 to destroy.
```
 - Запустил инстанс VM, описание характеристик которого описал в конфигурационном файле **main.tf**:
```sh
$ terraform apply
google_compute_instance.app: Creating...
google_compute_instance.app: Still creating... [10s elapsed]
google_compute_instance.app: Still creating... [20s elapsed]
google_compute_instance.app: Still creating... [30s elapsed]
google_compute_instance.app: Creation complete after 32s [id=reddit-app]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
Начиная с версии 0.11 terraform apply запрашивает
дополнительное подтверждение при выполнении. Необходимо
добавить -auto-approve для отключения этого.

Результатом выполнения команды также будет создание файла
terraform.tfstate в директории terraform.

Terraform хранит в этом файле состояние управляемых ресурсов.

Нашел внешний IP адрес созданного инстанса используя команду **show**:
```sh
$ terraform show | grep nat_ip
            nat_ip       = "146.148.116.133"
```
Попробовал подключиться через ssh использовав внешний ip инстанса. 
Не получилось, потому что я удалил ssh ключ из метаданных проекта.

 - Определил SSH ключ в метаданных нашего инстанса. Добавив в main.tf:
```sh
resource "google_compute_instance" "app" {
...
  metadata = {
    # путь до публичного ключа
    ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
  }
...
}
```
## Output vars
 - Внесем интересующую нас информацию в выходную переменную (output variable):
Для удобства вынесем выходные переменные в отдельный файл. 
Имя ему можно дать любое, главное назначить ему расширение .tf
 - Создадаем файл **outputs.tf** с содержимым:
```sh
output "app_external_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
```
 - Используем команду terraform refresh, чтобы выходная переменная приняла значение:
```sh
$ terraform refresh
google_compute_instance.app: Refreshing state... [id=reddit-app]
Outputs:
app_external_ip = 146.148.116.133
```
terraform output - просмотр значений выходных переменных:
```sh
$ terraform output
app_external_ip = 146.148.116.133
```
 - Определяем правило фаервола для нашего приложения:
```sh
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
```

 - Добавляем тег инстансу VM в файл **main.tf**:
```sh
resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "g1-small"
  zone = "europe-west1-b"
  tags = ["reddit-app"]
...
```

Provisioners в terraform используют для запуска инструментов управления конфигурацией 
или начальной настройки системы в момент создания/удаления ресурса.

Мы же используем провиженеры для деплоя последней версии приложения на созданную VM.
Внутрь main.tf вставляем секцию провижинера типа **file**, который позволяет копировать содержимое файла на удаленную машину:
```sh
provisioner "file" {
  source = "files/puma.service"
  destination = "/tmp/puma.service"
}
```
 - Создадим файл **puma.service** внутри директории terraform/files/ с содержимым:
```sh
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
 - Добавим еще один провиженер для запуска скрипта деплоя приложения:
```sh
provisioner "remote-exec" {
  script = "files/deploy.sh"
}
```
 - Создаем файл terraform/files/deploy.sh с содержимым:
```sh
#!/bin/bash
set -e

APP_DIR=${1:-$HOME}

git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
```
 - Указываем параметры подключения провижинеров к созданной VM по SSH:
```sh
connection {
  type = "ssh"
  host = self.network_interface[0].access_config[0].nat_ip
  user = "appuser"
  agent = false
  # путь до приватного ключа
  private_key = file("~/.ssh/appuser")
}
```
 - Пересоздаем VM для проверки провижинеров:
taint - позволяет пометить ресурс для пересоздания, при следующем запуске terraform apply
```sh
$ terraform taint google_compute_instance.app
Resource instance google_compute_instance.app has been marked as tainted.
```
 - Планируем изменения:
```sh
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
google_compute_firewall.firewall_puma: Refreshing state... [id=allow-puma-default]
google_compute_instance.app: Refreshing state... [id=reddit-app]
Plan: 1 to add, 0 to change, 1 to destroy.
```
 - Принял изменения и проверил работу приложения взяв ip из output и открыл страницу в браузере с портом 9292.

## Input vars
Входные переменные позволяют параметризировать конфигурационные файлы.
 - Создадим файл variables.tf  в директории terraform и определим переменные в этом файле:
```sh
variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
```
 - Определим соответствующие параметры ресурсов main.tf через переменные используя синтаксис var.var_name:
```sh
provider "google" {
  version = "2.15.0"
  project = var.project
  region = var.region
}
...
boot_disk {
  initialize_params {
    image = var.disk_image
  }
}
...
metadata = {
  ssh-keys = "appuser:${file(var.public_key_path)}"
}
...
```
 - Далее определим переменные используя специальный файл **terraform.tfvars**:
```sh
project = "infra-254011"
public_key_path = "~/.ssh/appuser.pub"
disk_image = "reddit-base"
```
## The final test
Для финальной проверки выполнил по порядку команды:
 - terraform destroy
 - terraform plan
 - terraform apply
terraform destroy - удаление всех созданных ресурсов
```sh
$ terraform destroy
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

google_compute_firewall.firewall_puma: Destroying... [id=allow-puma-default]
google_compute_instance.app: Destroying... [id=reddit-app]
google_compute_firewall.firewall_puma: Still destroying... [id=allow-puma-default, 10s elapsed]
google_compute_instance.app: Still destroying... [id=reddit-app, 10s elapsed]
google_compute_firewall.firewall_puma: Destruction complete after 17s
google_compute_instance.app: Still destroying... [id=reddit-app, 20s elapsed]
google_compute_instance.app: Still destroying... [id=reddit-app, 30s elapsed]
google_compute_instance.app: Still destroying... [id=reddit-app, 40s elapsed]
google_compute_instance.app: Still destroying... [id=reddit-app, 50s elapsed]
google_compute_instance.app: Still destroying... [id=reddit-app, 1m0s elapsed]
google_compute_instance.app: Destruction complete after 1m9s

Destroy complete! Resources: 2 destroyed.
```

 - Переходим на сайт по адресу из Output и используя порт 9292

## Самостоятельная работа
 1. Определяем input переменную для приватного ключа(connection):
 - В файл variables.tf определил переменную *private_key*:
```sh
variable private_key {
  description = "User private key"
}
```
 - Определяем соотвествующие параметр в файле main.tf:
```sh
 connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "appuser"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key)
  }
```
	 private_key = file("~/.ssh/appuser")
 - Определил переменные в файле terraform.tfvars:
```sh
project         = "infra-254011"
public_key_path = "~/.ssh/appuser.pub"
disk_image      = "reddit-base"
private_key     = "~/.ssh/appuser"
```
 2. Определил input переменную для задания зоны в ресурсе "google_compute_instance" "app".
Дал значение по умолчанию:
variables.tf:
```sh
variable zone_default {
  description = "zone"
  default = "europe-west1-b"
}
```
main.tf:
```sh
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone_default
  tags         = ["reddit-app"]
...
```
 3. Отформатировал все конфиги используя `terraform fmt` :
```sh
$ terraform fmt
main.tf
terraform.tfvars
variables.tf
```
 4. Создал файл **terraform.tfvars.example** :
```sh
project = "your_project_id"
public_key_path = "~/.ssh/appuser.pub"
private_key_path = "~/.ssh/appuser"
disk_image = "reddit-base"
```

## Доп. задание
 - Добавление ключа пользователя appuser1 в метаданные проекта:
```sh
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}
```

 - Добавление нескольких ключей в метаданные проекта:
```sh
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = join("\n", var.ssh_keys)
}
```
 - При добавлении ssh ключа в метаданные проекта через web, после принятия конфига main.tf ssh-ключ добавленный через web был удален.

#HW7. Terraform-2
PR:

`terraform import` - добавляет информацию о созданном без помощи Terraform ресурсе в state файл.

Пример:

```sh
$ terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```

`terraform get` - загрузка модулей из указанного источника source.

##Самостоятельное задание

Создал модуль **vpc** в директории *modules/vpc/*:

**main.tf**

```sh
# vpc.tf
resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.source_ranges
}
```

**variables.tf**

```sh
variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}
```

Секция вызова модуля **vpc**

```sh
module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

```

## Модуль storage-bucket

**storage-bucket.tf**

```sh
provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"
  location = var.region
  # Èìÿ ïîìåíÿéòå íà äðóãîå
  name = "storage-bucket-testplayjim"
}

output storage-bucket_url {
  value = module.storage-bucket.url
}
```

**variable.tf**

```sh
variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  default     = "europe-west1"
}
```



