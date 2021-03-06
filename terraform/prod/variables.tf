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
variable private_key {
  description = "User private key"
}
variable zone_default {
  description = "zone"
  default     = "europe-west1-b"
}
variable ssh_keys {
  description = "Users ssh-keys. Format -> user:ssh-key"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-db-base"
}

