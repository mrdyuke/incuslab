# provider.tf
# Configures the Incus cloud provider for managing infrastructure resources.
# Defines the required provider "incus" from lxc source.

terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

provider "incus" {}