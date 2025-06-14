variable "platform" {
  description = "Platform für das Talos-Image"
  type        = string
  default     = "metal"
}

variable "pool" {
  description = "Pool für das Libvirt-Volume"
  type        = string
  default     = "default"
}
