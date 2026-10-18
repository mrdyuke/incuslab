# instance.tf
# Defines three virtual machine instances (vm-1, vm-2, vm-3) using ArchLinux cloud images.
# Each instance has 1 CPU limit, no secureboot, and autostart enabled.
# Instances attach to storage pool pool-1 and respective network interfaces.

# Output variables for Ansible inventory
# Note: Dynamic DHCP IPs are not directly available as Terraform attributes
# in this Incus provider version. Use `terraform output` after apply
# to inspect available attributes, or use a null_resource with
# local-exec to capture IPs via `incus list` or API queries.

output "instance_status" {
  value = {
    vm1_status = incus_instance.vm-1.status
    vm2_status = incus_instance.vm-2.status
    vm3_status = incus_instance.vm-3.status
  }
}

resource "incus_instance" "vm-1" {
  name  = "vm-1"
  image = "images:archlinux/current/cloud"
  type  = "virtual-machine"

  config = {
    "security.secureboot" = false
    "boot.autostart" = true
    "limits.cpu"     = 1
  }

  device {
    name = "pool-1"
    type = "disk"

    properties = {
      path = "/"
      pool = incus_storage_pool.pool-1.name
    }
  }

  device {
    name = "public-net-1"
    type = "nic"

    properties = {
      network = incus_network.public-net-1.name
    }
  }
}

resource "incus_instance" "vm-2" {
  name  = "vm-2"
  image = "images:archlinux/current/cloud"
  type  = "virtual-machine"

  config = {
    "security.secureboot" = false
    "boot.autostart" = true
    "limits.cpu"     = 1
  }

  device {
    name = "pool-1"
    type = "disk"

    properties = {
      path = "/"
      pool = incus_storage_pool.pool-1.name
    }
  }

  device {
    name = "private-net-1"
    type = "nic"

    properties = {
      network = incus_network.private-net-1.name
    }
  }
}

resource "incus_instance" "vm-3" {
  name  = "vm-3"
  image = "images:archlinux/current/cloud"
  type  = "virtual-machine"

  config = {
    "security.secureboot" = false
    "boot.autostart" = true
    "limits.cpu"     = 1
  }

  device {
    name = "pool-1"
    type = "disk"

    properties = {
      path = "/"
      pool = incus_storage_pool.pool-1.name
    }
  }

  device {
    name = "private-net-1"
    type = "nic"

    properties = {
      network = incus_network.private-net-1.name
    }
  }
}