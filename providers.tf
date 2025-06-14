terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

provider "talos" {}

provider "local" {}

provider "null" {}
