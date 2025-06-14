# Definiere lokale Variablen für die Templates
locals {
  # Controlplane-Patch mit yaml_encode, um sichere YAML-Syntax zu gewährleisten
  controlplane_patch = yamlencode({
    machine = {
      network = {
        hostname = "controlplane"
        interfaces = [
          {
            interface = "ens3"
                dhcp = true
                routes = [
                  {
                    network = "0.0.0.0/0"
                    gateway = cidrhost(var.network_cidr, 1)
                  }
                ]
            vip = {
              ip = var.controlplane_endpoint
            }
          }
        ]
      }
      install = {
        disk = "/dev/vda"
      }
      kubelet = {
        extraArgs = {
          "feature-gates" = "GracefulNodeShutdown=true"
        }
        nodeIP = {
          validSubnets = [var.network_cidr]
        }
      }
      sysctls = {
        "net.core.somaxconn" = 65535
        "net.core.netdev_max_backlog" = 4096
        "net.ipv4.ip_forward" = 1
      }
    }
  })

  # Worker-Patch mit yaml_encode
  worker_patch = yamlencode({
    machine = {
      network = {
        hostname = "worker"
        interfaces = [
          {
            interface = "ens3"
                dhcp = false
                routes = [
                  {
                    network = "0.0.0.0/0"
                    gateway = cidrhost(var.network_cidr, 1)
                  }
                ]
          }
        ]
      }
      install = {
        disk = "/dev/vda"
      }
      kubelet = {
        extraArgs = {
          "feature-gates" = "GracefulNodeShutdown=true"
        }
        nodeIP = {
          validSubnets = [var.network_cidr]
        }
      }
      sysctls = {
        "net.core.somaxconn" = 65535
        "net.core.netdev_max_backlog" = 4096
        "net.ipv4.ip_forward" = 1
      }
    }
  })

  # Cluster-Konfiguration
  cluster_patch = yamlencode({
    cluster = {
      network = {
        cni = {
          name = "flannel"
        }
        podSubnets = ["10.244.0.0/16"]
        serviceSubnets = ["10.96.0.0/12"]
      }
      allowSchedulingOnMasters = true
    }
  })
}

# Erstellt die Konfiguration für den Talos-Cluster
resource "talos_machine_secrets" "this" {}

# Konfiguration für Controlplane-Nodes erstellen
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.controlplane_endpoint}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    local.controlplane_patch,
    local.cluster_patch
  ]
}

# Konfiguration für Worker-Nodes erstellen
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.controlplane_endpoint}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    local.worker_patch
  ]
}

# Stellt die Kontrollebenen-Konfiguration für die Controlplane-Nodes bereit
resource "talos_machine_configuration_apply" "controlplane" {
  count = length(var.controlplane_ips)

  client_configuration = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                 = var.controlplane_ips[count.index]
  endpoint             = var.controlplane_ips[0]

}

# Stellt die Worker-Konfiguration für die Worker-Nodes bereit
resource "talos_machine_configuration_apply" "worker" {
  count = length(var.worker_ips)

  client_configuration = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                 = var.worker_ips[count.index]
  endpoint             = var.controlplane_ips[0]

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# Bootstrappt den Talos-Cluster
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]
  endpoint             = var.controlplane_ips[0]

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# Bootstrappt den Talos-Cluster
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]
  endpoint             = var.controlplane_ips[0]

  depends_on = [talos_machine_configuration_apply.controlplane]
}
