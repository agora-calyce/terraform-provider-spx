# Internal load balancer targeting the instances carrying a label
resource "spx_load_balancer" "selectors" {
  name      = "my-lb-selectors"
  vip       = "198.18.0.20"
  selectors = ["app:web"]

  ports {
    port        = 80
    target_port = 80
    protocol    = "TCP"
  }
}

# Load balancer targeting fixed IP addresses
resource "spx_load_balancer" "endpoints" {
  name      = "my-lb-endpoints"
  vip       = "198.18.0.21"
  endpoints = ["10.11.12.10", "10.11.12.11"]

  ports {
    port        = 80
    target_port = 8080
    protocol    = "TCP"
  }

  ports {
    port        = 443
    target_port = 8443
    protocol    = "TCP"
  }
}
