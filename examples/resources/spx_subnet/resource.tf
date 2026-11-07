resource "spx_vpc" "example" {
  name = "my-vpc"
}

# Public IPv4 subnet with a NAT gateway for outbound Internet access
resource "spx_subnet" "example" {
  name        = "my-subnet"
  vpc_id      = spx_vpc.example.id
  protocol    = "IPv4"
  ipv4        = "10.11.12.0/24"
  private     = false
  dns_v4      = "8.8.8.8"
  nat_gateway = true
}
