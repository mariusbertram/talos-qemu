variable "name_prefix" {
  description = "Präfix für den Namen der Node"
  type        = string
}

variable "node_count" {
  description = "Anzahl der zu erstellenden Nodes"
  type        = number
}

variable "memory" {
  description = "Arbeitsspeicher in MB"
  type        = string
  default     = "4096"
}

variable "vcpu" {
  description = "Anzahl der virtuellen CPUs"
  type        = string
  default     = "2"
}

variable "disk_size" {
  description = "Größe der Festplatte in Bytes"
  type        = number
  default     = 30000000000
}

variable "network_name" {
  description = "Name des zu verwendenden Netzwerks"
  type        = string
  default     = ""
}

variable "bridge_name" {
  description = "Name der zu verwendenden Bridge"
  type        = string
  default     = "br0"
}

variable "ip_prefix" {
  description = "Präfix für die IP-Adressen"
  type        = string
}

variable "talos_base_volume_id" {
  description = "ID des Talos Basis-Disk-Images"
  type        = string
}

variable "pool" {
  description = "Pool für die Libvirt-Volumes"
  type        = string
  default     = "default"
}
