variable "cluster_name" {
  description = "Name des Kubernetes-Clusters"
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

variable "talos_client_configuration" {
  description = "Die Talos-Client-Konfiguration im JSON-Format"
  type        = string
  sensitive   = true
}

variable "cilium_version" {
  description = "Die zu installierende Cilium-Version (Helm-Chart Version)"
  type        = string
  default     = "1.17.4"
}

variable "cilium_values_path" {
  description = "Der Pfad zur Cilium-Werte-Datei"
  type        = string
  default     = "files/cilium-values.yaml"
}

variable "machine_config_target" {
  description = "Der Zieltyp für den Talos-Konfigurationspatch (controlplane oder worker)"
  type        = string
  validation {
    condition     = contains(["controlplane", "worker", "all"], var.machine_config_target)
    error_message = "Der machine_config_target muss entweder 'controlplane', 'worker' oder 'all' sein."
  }
}
