# Instance types available for the vm_type argument of spx_instance
data "spx_vm_types" "all" {}

output "vm_types" {
  value = data.spx_vm_types.all.types
}
