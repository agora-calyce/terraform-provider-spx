# Terraform SPX Provider

This Terraform provider allows you to interact with the SPX API to manage infrastructure resources such as VPCs, subnets, Elastic IPs (EIPs), and disks.

It talks to the [SPX TF Proxy API](https://github.com/Agora-Calyce/spx-tf-api), which must be reachable at the configured `endpoint`.

> **Transparency Note**: This project was “vibecoded.” It certainly has room for improvement, and all contributions are welcome!

## Installation

The provider can be used either from the Terraform Registry (recommended) or from a local build (for development).

### From the Terraform Registry

The provider is published as [`agora-calyce/spx`](https://registry.terraform.io/providers/agora-calyce/spx/latest). Declare it in `required_providers` and run `terraform init`: Terraform downloads it automatically.

```hcl
terraform {
  required_providers {
    spx = {
      source  = "agora-calyce/spx"
      version = "~> 1.0"
    }
  }
}
```

```bash
terraform init
```

To move to a newer version, change the `version` constraint and run `terraform init -upgrade`.

### From a local build

Requires Go (see `go.mod` for the version).

```bash
make build
```

This compiles the binary and copies it into Terraform's implicit local mirror: `~/.terraform.d/plugins/registry.terraform.io/agora-calyce/spx/<VERSION>/<OS>_<ARCH>/`, where `<VERSION>` is the `VERSION` variable of the `Makefile` (`1.0.0` by default).

The Terraform configuration stays the same as for the Registry (`source = "agora-calyce/spx"`), but the `version` constraint must match the locally installed version:

```hcl
terraform {
  required_providers {
    spx = {
      source  = "agora-calyce/spx"
      version = "1.0.0"
    }
  }
}
```

Then, in the Terraform project:

```bash
rm -f .terraform.lock.hcl   # the checksum of a local build differs from the published one
terraform init
```

After each rebuild with the same version, delete `.terraform.lock.hcl` and run `terraform init` again.

> **Note**: as long as the `~/.terraform.d/plugins/registry.terraform.io/agora-calyce/spx/` directory exists, Terraform installs the versions it contains from there instead of the Registry. To go back to the published provider, delete that directory (or pin a version that is not installed locally), then run `terraform init -upgrade`.

#### Alternative: `dev_overrides`

To iterate without `terraform init` or version handling, point Terraform directly at the build directory in `~/.terraformrc`:

```hcl
provider_installation {
  dev_overrides {
    "agora-calyce/spx" = "/path/to/terraform-provider-spx"
  }
  direct {}
}
```

Build with `go build -o terraform-provider-spx`, then run `terraform plan` / `terraform apply` directly (Terraform prints a warning reminding you that the override is active). Remove the block to go back to the Registry.

## Provider Configuration

```hcl
provider "spx" {
  endpoint   = "http://localhost:8080"
  api_token  = "your-api-token"
  az         = "az-name"
  orga_id    = "your-orga-id"
  project_id = "your-project-id"
}
```

All arguments can also be set through environment variables (see below), which avoids writing the API token in the configuration.

### Environment Variables

You can also configure the provider using environment variables:

| Variable | Description |
| --- | --- |
| `SPX_API_ENDPOINT` | API endpoint (default: `http://localhost:8080`) |
| `SPX_API_TOKEN` | API token for authentication |
| `SPX_AZ` | Availability Zone |
| `SPX_ORGA_ID` | Organization ID |
| `SPX_PROJECT_ID` | Project ID |

## Examples

The `examples` folder has two kinds of content:

- `examples/projects/<resource>/`: runnable Terraform projects, one per resource, plus `full/` (VM + EIP + load balancer + security group). Fill in `terraform.tfvars`, then run `terraform init && terraform apply`.
- `examples/provider/`, `examples/resources/<type>/` and `examples/data-sources/<type>/`: short snippets that `make docs` puts in the "Example Usage" section of each Registry page.

## Releasing

Pushing a `vX.Y.Z` tag triggers the `Release` workflow: GoReleaser builds the binaries for every platform, signs the checksums with GPG and publishes a GitHub release that the Terraform Registry picks up.

It needs two repository secrets: `GPG_PRIVATE_KEY` (ASCII-armored private key, whose public key is registered in the Terraform Registry) and `PASSPHRASE`.
