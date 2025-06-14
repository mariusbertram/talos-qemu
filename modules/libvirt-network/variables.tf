variable "network_name" {
  description = "Name des Netzwerks"
  type        = string
}

variable "network_mode" {
  description = "Modus des Netzwerks"
  type        = string
  default     = "open"
}

variable "domain" {
  description = "Domain des Netzwerks"
  type        = string
}

variable "addresses" {
  description = "Adressbereiche des Netzwerks"
  type        = list(string)
}

variable "dhcp_enabled" {
  description = "DHCP aktivieren"
  type        = bool
  default     = true
}

variable "autostart" {
  description = "Autostart des Netzwerks"
  type        = bool
  default     = true
}
