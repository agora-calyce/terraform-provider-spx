terraform {
  required_providers {
    spx = {
      source = "Agora-Calyce/spx"
    }
  }
}

# The provider talks to the SPX TF Proxy API, not to the SPX console API directly.
# Every argument can also be set with an environment variable
# (SPX_API_ENDPOINT, SPX_API_TOKEN, SPX_AZ, SPX_ORGA_ID, SPX_PROJECT_ID).
provider "spx" {
  endpoint   = "https://console.example.com/tf-api"
  api_token  = var.spx_api_token
  az         = "fr01-lyo01"
  orga_id    = "00000000-0000-0000-0000-000000000000"
  project_id = "00000000-0000-0000-0000-000000000000"
}

variable "spx_api_token" {
  type      = string
  sensitive = true
}
