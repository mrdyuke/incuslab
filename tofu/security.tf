# security.tf
# Defines network ACLs for zone segmentation: acl-dmz exposes SSH/HTTP/HTTPS/DNS/DHCP,
# while acl-internal allows same-subnet traffic and SSH from DMZ only.

resource "incus_network_acl" "acl-dmz" {
  name        = "acl-dmz"
  description = "DMZ ACL for public-net-1: expose SSH/HTTP/HTTPS only, allow DNS/DHCP, reject everything else"

  ingress = [
    {
      action      = "allow"
      state       = "enabled"
      protocol    = "udp"
      source_port = "53"
      description = "DNS replies from any resolver"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      source_port = "53"
      description      = "DNS replies from any resolver (TCP)"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "udp"
      source           = "10.10.10.1"
      destination_port = "67,68"
      description      = "DHCP to/from network gateway"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      destination_port = "22,80,443"
      description      = "SSH/HTTP/HTTPS into the DMZ (from internet and internal networks)"
    },
    {
      action      = "allow"
      state       = "enabled"
      protocol    = "icmp4"
      description = "ICMP into the DMZ"
    },
  ]

  egress = [
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "udp"
      destination_port = "53"
      description      = "DNS lookups"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      destination_port = "53"
      description      = "DNS lookups (TCP)"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "udp"
      destination_port = "67"
      description      = "DHCP requests"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      destination_port = "80,443"
      description      = "Outbound HTTP/HTTPS (package updates etc.)"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      destination      = "10.10.20.0/24"
      destination_port = "22"
      description      = "SSH from DMZ into the internal zone (bastion jump)"
    },
    {
      action      = "allow"
      state       = "enabled"
      protocol    = "icmp4"
      description = "Outbound ICMP (diagnostics)"
    },
  ]
}

resource "incus_network_acl" "acl-internal" {
  name        = "acl-internal"
  description = "Internal ACL for private-net-1: same-subnet traffic + SSH from DMZ, nothing else inbound"

  ingress = [
    {
      action      = "allow"
      state       = "enabled"
      source      = "10.10.20.0/24"
      description = "Allow traffic from the same subnet (instances and gateway DHCP/DNS replies)"
    },
    {
      action           = "allow"
      state            = "enabled"
      source           = "10.10.10.0/24"
      protocol         = "tcp"
      destination_port = "22"
      description      = "SSH from the DMZ (bastion jump host only)"
    },
  ]
}