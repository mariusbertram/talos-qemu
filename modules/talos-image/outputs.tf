output "disk_image_url" {
  description = "URL des Talos Disk-Images"
  value       = data.talos_image_factory_urls.this.urls.disk_image
}

output "highest_stable_version" {
  description = "Die höchste stabile Talos-Version"
  value       = local.highest_stable_version
}

output "talos_base_volume_id" {
  description = "Die ID des Talos Basis-Disk-Images"
  value       = libvirt_volume.talos_disk_image.id
}
