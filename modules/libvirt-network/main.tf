resource "libvirt_network" "network" {
  name      = var.network_name
  mode      = var.network_mode
  domain    = var.domain
  addresses = var.addresses
  dhcp {
    enabled = var.dhcp_enabled
  }
  autostart = var.autostart
}
