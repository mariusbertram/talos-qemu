output "nodes" {
  description = "Liste der erstellten Nodes"
  value       = libvirt_domain.node
}

output "ip_addresses" {
  description = "IP-Adressen der erstellten Nodes"
  value       = libvirt_domain.node[*].network_interface[0].addresses[0]
}
