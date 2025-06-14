output "network_name" {
  description = "Name des erstellten Netzwerks"
  value       = libvirt_network.network.name
}

output "network_id" {
  description = "ID des erstellten Netzwerks"
  value       = libvirt_network.network.id
}
