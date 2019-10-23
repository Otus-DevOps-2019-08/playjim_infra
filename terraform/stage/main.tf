terraform {
  # Версия terraform
  required_version = "~> 0.12.8"
  required_providers {
    google = "~>2.7"
  }
}

provider "google" {
  # Версия провайдера
  version = "2.15"

  # ID проекта
  project = var.project

  region = var.region
}

module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone_default    = var.zone_default
  app_disk_image  = var.app_disk_image
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone_default    = var.zone_default
  db_disk_image   = var.db_disk_image
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

