variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable zone_default {
  description = "zone"
  default     = "europe-west1-b"
}
variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-db-base"
}

