locals {
  gate_ingresses = [
    { port : "22", cidr : [var.MY_IP] },
    { port : "80", cidr : ["0.0.0.0/0"] },
    { port : "443", cidr : ["0.0.0.0/0"] }
  ]
}

resource "yandex_vpc_network" "default" {}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  description    = "Auto-created default subnet for zone ru-central1-a in default"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-to-internet"
  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_security_group" "keycloak" {
  name       = "keycloak"
  network_id = yandex_vpc_network.default.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }

  dynamic "ingress" {
    for_each = local.gate_ingresses
    content {
      protocol          = lookup(ingress.value, "protocol", "TCP")
      v4_cidr_blocks    = lookup(ingress.value, "cidr", [])
      security_group_id = lookup(ingress.value, "sg_id", "")
      port              = lookup(ingress.value, "port", [])
    }
  }
}
