resource "yandex_compute_instance" "keycloak" {
  name                      = "keycloak"
  hostname                  = "keycloak"
  labels                    = { group = "auth" }
  platform_id               = "standard-v2"
  allow_stopping_for_update = true
  service_account_id        = var.YC_KEYS.service_account_id

  resources {
    core_fraction = 5
    cores         = 2
    memory        = 4
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = var.image_id
      size     = 10
      #type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default-ru-central1-a.id
    security_group_ids = [yandex_vpc_security_group.keycloak.id]
    nat                = true
  }

  metadata = {
    user-data = "${templatefile("meta.tftpl", { ssh_pub_key = file("~/.ssh/id_ed25519.pub") })}"
  }
}
