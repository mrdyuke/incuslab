// https://github.com/lxc/terraform-provider-incus

terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

provider "incus" {}
