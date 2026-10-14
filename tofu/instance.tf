resource "incus_instance" "vm-1" {
  name  = "vm-1"
  image = "images:archlinux/current/cloud"
  type  = "virtual-machine"
  profiles = []

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
  profiles = []

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
  profiles = []

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
