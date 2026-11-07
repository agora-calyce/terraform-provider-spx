resource "spx_ssh_key" "example" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

output "ssh_key_fingerprint" {
  value = spx_ssh_key.example.fingerprint
}
