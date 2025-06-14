output "talos_disk_image_url" {
  description = "URL des Talos Disk-Images"
  value       = module.talos_image.disk_image_url
}

output "highest_stable_version" {
  description = "Die höchste stabile Talos-Version"
  value       = module.talos_image.highest_stable_version
}

output "controlplane_ips" {
  description = "IP-Adressen der Control-Plane-Nodes"
  value       = module.controlplane.ip_addresses
}

output "worker_ips" {
  description = "IP-Adressen der Worker-Nodes"
  value       = module.worker.ip_addresses
}

output "kubeconfig" {
  description = "Kubeconfig für den Zugriff auf den Kubernetes-Cluster"
  value       = module.talos_cluster.kubeconfig
  sensitive   = true
}

output "talosconfig" {
  description = "Talosconfig für den Zugriff auf den Talos-Cluster"
  value       = module.talos_cluster.talosconfig
  sensitive   = true
}

output "kubeconfig_path" {
  description = "Pfad zur gespeicherten Kubeconfig-Datei"
  value       = local_sensitive_file.kubeconfig.filename
}

output "talosconfig_path" {
  description = "Pfad zur gespeicherten Talosconfig-Datei"
  value       = local_sensitive_file.talosconfig.filename
}

output "cluster_endpoint" {
  description = "Endpunkt des Kubernetes-Clusters"
  value       = "https://${var.controlplane_endpoint}:6443"
}
