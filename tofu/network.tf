# network.tf
# Configures two bridge networks: public-net-1 with DMZ security ACLs and NAT,
# and private-net-1 with internal zone restrictions and allow egress.

resource "incus_network" "public-net-1" {
  name = "public-net-1"
  type = "bridge"

  config = {
    "ipv4.address"      = "10.10.10.1/24"
    "ipv4.nat"          = "true"
    "ipv4.dhcp"         = "true"
    "ipv4.dhcp.gateway" = "10.10.10.1"

    "ipv6.address" = "none"
    "ipv6.nat"     = "false"

    # DMZ zone: only traffic matching acl-dmz rules is let through.
    # Egress also allows tcp/22 into the internal subnet (bastion jump).
    "security.acls"                        = incus_network_acl.acl-dmz.name
    "security.acls.default.ingress.action" = "reject"
    "security.acls.default.egress.action"  = "reject"
  }
}

resource "incus_network" "private-net-1" {
  name = "private-net-1"
  type = "bridge"

  config = {
    "ipv4.address"      = "10.10.20.1/24"
    "ipv4.nat"          = "true"
    "ipv4.dhcp"         = "true"
    "ipv4.dhcp.gateway" = "10.10.20.1"

    "ipv6.address" = "none"
    "ipv6.nat"     = "false"

    # Internal zone: inbound only from the local subnet and SSH (tcp/22)
    # from the DMZ (acl-internal), outbound left open so instances can reach
    # the internet through NAT.
    "security.acls"                        = incus_network_acl.acl-internal.name
    "security.acls.default.ingress.action" = "reject"
    "security.acls.default.egress.action"  = "allow"
  }
}