resource "spx_vpc" "example" {
  name = "my-vpc"
}

resource "spx_subnet" "example" {
  name        = "my-subnet"
  vpc_id      = spx_vpc.example.id
  protocol    = "IPv4"
  ipv4        = "10.11.12.0/24"
  nat_gateway = true
}

resource "spx_disk" "boot" {
  name          = "my-boot-disk"
  size          = 20
  storage_class = "block-standard"

  source {
    type = "http"
    url  = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  }
}

resource "spx_ssh_key" "admin" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "spx_instance" "example" {
  name         = "my-instance"
  run_strategy = "Always"
  vm_type      = "debian" # see the spx_vm_types data source
  cpu          = 2
  memory       = 4

  network {
    order     = 0
    subnet_id = spx_subnet.example.id
    ipv4      = "10.11.12.10"
  }

  disks {
    order   = 0
    disk_id = spx_disk.boot.id
  }

  cloud_init {
    custom = true
    config = <<-EOT
      #cloud-config
      package_update: true
      packages:
        - nginx
    EOT
  }

  ssh_keys = [spx_ssh_key.admin.id]
  labels   = ["user.superphenix.net/app:web"]

  # Advanced options: any value not set is inherited from the vm_type.
  # advanced {
  #   efi {
  #     secure_boot = true
  #   }
  # }
}

output "instance_ip" {
  value = spx_instance.example.ip_address
}
