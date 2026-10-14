// Network ACLs: public-net-1 acts as DMZ, private-net-1 is the internal zone.
//
// Design notes:
// - All rules are "allow" (never mixed with drop/reject): incus_network_acl
//   exposes ingress/egress as sets, so rule order is not guaranteed. With only
//   allow rules + "reject" as the network default action, the result does not
//   depend on evaluation order.
// - "allow" is stateful on bridge networks (nftables, ct state
//   established,related accept), so reply traffic passes without extra rules.

// ---------------------------------------------------------------------------
// DMZ zone: attached to public-net-1 (10.10.10.0/24).
// Internet-facing services live here; only inbound SSH/HTTP/HTTPS is exposed.
// ---------------------------------------------------------------------------
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
      action      = "allow"
      state       = "enabled"
      protocol    = "tcp"
      source_port = "53"
      description = "DNS replies from any resolver (TCP)"
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

// ---------------------------------------------------------------------------
// Internal zone: attached to private-net-1 (10.10.20.0/24).
// Same-subnet traffic plus SSH (tcp/22) from the DMZ subnet, so a bastion host
// in the DMZ can jump in. Everything else initiated from DMZ/internet is
// rejected by the network default action. Egress is open so instances can
// reach the internet through NAT.
// ---------------------------------------------------------------------------
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
