output "kubeconfig" {
  description = "Der Kubeconfig-Inhalt für den Zugriff auf den Kubernetes-Cluster"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "client_configuration" {
  description = "Die Talos-Client-Konfiguration"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "talosconfig" {
  description = "Die Talosconfig für den Zugriff auf den Talos-Cluster"
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
}

output "talosconfig_raw" {
  description = "Talosconfig als Rohtext für die Dateiausgabe"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}