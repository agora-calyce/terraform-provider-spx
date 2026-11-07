# Public HTTP/HTTPS and SSH from an admin network for the instances labelled app:web,
# outbound traffic allowed
resource "spx_security_group" "web" {
  name        = "my-sg-web"
  description = "Public HTTP, SSH from the admin network"

  # Optional: limits the security group to these subnets (10 maximum).
  # If not set, it applies to all subnets of the project.
  # subnet_ids = [spx_subnet.example.id]

  target {
    match_labels = ["user.superphenix.net/app:web"]
  }

  ingress {
    ports {
      port     = 80
      protocol = "TCP"
    }
    ports {
      port = 443 # TCP by default
    }
    from {
      ip_block {
        cidr = "0.0.0.0/0"
      }
    }
  }

  ingress {
    ports {
      port = 22
    }
    from {
      ip_block {
        cidr = "203.0.113.0/24"
      }
    }
  }

  egress {
    allow_all = true
  }
}

# Target selected by expression, traffic allowed from instances carrying a label
resource "spx_security_group" "from_bastion" {
  name = "my-sg-from-bastion"

  target {
    match_expressions {
      key      = "user.superphenix.net/env"
      operator = "In"
      values   = ["prod", "staging"]
    }
  }

  ingress {
    ports {
      port = 22
    }
    from {
      pod_selector {
        match_labels = ["user.superphenix.net/role:bastion"]
      }
    }
  }
}
