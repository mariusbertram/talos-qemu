variable "cluster_name" {
  description = "Name des Kubernetes-Clusters"
  type        = string
  default     = "talos-k8s"
}

variable "controlplane_endpoint" {
  description = "Der Endpunkt (VIP) für die Kontrollebene des Clusters"
  type        = string
}

variable "controlplane_ips" {
  description = "Liste der IP-Adressen der Controlplane-Nodes"
  type        = list(string)
}

variable "worker_ips" {
  description = "Liste der IP-Adressen der Worker-Nodes"
  type        = list(string)
}

variable "network_cidr" {
  description = "Das CIDR-Netzwerk, in dem sich die Nodes befinden"
  type        = string
  default     = "192.168.100.0/24"
}

