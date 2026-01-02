# разворачиваем окружение в YC
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "storwize"
    region = "ru-central1"
    key    = "keycloak/k8s.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
    skip_s3_checksum            = true # This option is required to describe a backend for Terraform version 1.6.3 or higher.

  }

  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = "ru-central1-a"
  folder_id = var.YC_KEYS.folder_id
}
