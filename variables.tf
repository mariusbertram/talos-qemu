variable "controlplane" {
  description = "Anzahl der Control-Plane-Nodes"
  type        = number
  default     = 3
}

variable "worker" {
  description = "Anzahl der Worker-Nodes"
  type        = number
  default     = 3
}

variable "libvirt_uri" {
  description = "URI des Libvirt-Providers"
  type        = string
  default     = "qemu+ssh://marius@192.168.178.60/system"
}

variable "libvirt_pool" {
  description = "Pool für die Libvirt-Volumes"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name des Kubernetes-Clusters"
  type        = string
  default     = "talos-k8s"
}

variable "controlplane_endpoint" {
  description = "Der Endpunkt (VIP) für die Kontrollebene des Clusters"
  type        = string
  default     = "192.168.100.99"
}

variable "network_cidr" {
  description = "Das CIDR-Netzwerk, in dem sich die Nodes befinden"
  type        = string
  default     = "192.168.100.0/24"
}

