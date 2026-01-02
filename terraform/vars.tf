variable "YC_KEYS" {
  type = object({
    folder_id          = string
    service_account_id = string
  })
  description = "ID облака YC и сервисного аккаунта"
}

variable "image_id" {
  type        = string
  description = "ID общедоступного дистрибутива для узлов k8s"
  default     = "fd84621h182isl3ihi5i" # debian 12
}

variable "site_name" {
  type        = string
  description = "DNS-имя сайта"
}

variable "MY_IP" {
  type = string
}
