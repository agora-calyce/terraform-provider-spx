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

# EIP bound to a single internal IP (floating IP)
resource "spx_eip" "floating" {
  name        = "my-eip-floating"
  subnet_id   = spx_subnet.example.id
  internal_ip = "10.11.12.11"
}

# EIP shared by the subnet for outbound traffic (SNAT),
# forwarding inbound ports to an instance (DNAT)
resource "spx_eip" "nat" {
  name      = "my-eip-nat"
  subnet_id = spx_subnet.example.id
  snat      = [spx_subnet.example.ipv4]

  dnat {
    external_port = "80"
    internal_ip   = "10.11.12.10"
    internal_port = "80"
    protocol      = "tcp"
  }

  dnat {
    external_port = "2222"
    internal_ip   = "10.11.12.10"
    internal_port = "22"
    protocol      = "tcp"
  }
}

output "eip_nat_external_ip" {
  value = spx_eip.nat.external_ip
}
