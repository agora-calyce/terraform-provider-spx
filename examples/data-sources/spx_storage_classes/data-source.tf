# Storage classes available in the availability zone, sorted by name
data "spx_storage_classes" "all" {}

output "storage_classes" {
  value = data.spx_storage_classes.all.names
}
