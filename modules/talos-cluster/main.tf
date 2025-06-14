# Definiere lokale Variablen für die Templates
locals {
  # Controlplane-Patch mit yaml_encode, um sichere YAML-Syntax zu gewährleisten
  controlplane_patch = yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            interface = "ens3"
                dhcp = true
            vip = {
              ip = var.controlplane_endpoint
            }
          }
        ]
      }
      install = {
        disk = "/dev/vda"
      }
    }
  })

  # Worker-Patch mit yaml_encode
  worker_patch = yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            interface = "ens3"
                dhcp = true
          }
        ]
      }
      install = {
        disk = "/dev/vda"
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

data "talos_client_configuration" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.cluster_name
  nodes = concat(var.controlplane_ips, var.worker_ips)
}

# Konfiguration für Worker-Nodes erstellen
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.controlplane_ips[0]}:6443"
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

}

# Stellt die Worker-Konfiguration für die Worker-Nodes bereit
resource "talos_machine_configuration_apply" "worker" {
  count = length(var.worker_ips)

  client_configuration = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                 = var.worker_ips[count.index]

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# 30 Sekunden warten, bevor der Bootstrap ausgeführt wird
resource "time_sleep" "wait_before_bootstrap" {
  depends_on = [talos_machine_configuration_apply.controlplane]
  create_duration = "30s"
}

# Bootstrappt den Talos-Cluster
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]

  depends_on = [time_sleep.wait_before_bootstrap]
}

# Bootstrappt den Talos-Cluster
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]

  depends_on = [time_sleep.wait_before_bootstrap]
}
