# Blank data disk. Valid storage classes are listed by the spx_storage_classes data source.
resource "spx_disk" "data" {
  name          = "my-data-disk"
  size          = 10
  storage_class = "block-standard"
  labels        = ["user.superphenix.net/env:test"]

  source {
    type = "blank"
  }
}

# Boot disk imported from a cloud image
resource "spx_disk" "boot" {
  name          = "my-boot-disk"
  size          = 20
  storage_class = "block-standard"

  source {
    type = "http"
    url  = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  }
}
