# Cilium Helm-Repository und Werte vorbereiten
locals {
  # Template für Cilium-Werte rendern
  cilium_values_rendered = templatefile(
    var.cilium_values_path,
    {
      cluster_name = var.cluster_name
    }
  )

  # Erstellen des JSON-Patches im RFC6902 Format für Talos
  cilium_patches = jsonencode([
    {
      "op": "add",
      "path": "/cluster/network/cni",
      "value": {
        "name": "none"
      }
    },
    {
      "op": "add",
      "path": "/cluster/proxy",
      "value": {
        "disabled": true
      }
    },
    {
      "op": "add",
      "path": "/cluster/externalCloudProvider",
      "value": {
        "enabled": false
      }
    },
    {
      "op": "add",
      "path": "/cluster/helmRepositories",
      "value": [
        {
          "name": "cilium",
          "repository": "https://helm.cilium.io/"
        }
      ]
    },
    {
      "op": "add",
      "path": "/cluster/helmReleases",
      "value": [
        {
          "name": "cilium",
          "namespace": "kube-system",
          "repository": "cilium",
          "chart": "cilium",
          "version": var.cilium_version,
          "valuesContent": local.cilium_values_rendered
        }
      ]
    }
  ])
}

# Diese Ressource erstellt eine Datei mit dem Cilium-Patch
resource "local_file" "cilium_patch" {
  content  = local.cilium_patches
  filename = "${path.module}/cilium-helm-patch.json"
}

# Diese Ressource stellt die Cilium-Konfiguration für Controlplane-Nodes bereit
resource "talos_machine_configuration_apply" "controlplane_cilium" {
  count = var.machine_config_target == "controlplane" || var.machine_config_target == "all" ? length(var.controlplane_ips) : 0

  client_configuration = jsondecode(var.talos_client_configuration)
  machine_configuration_input = "Y2xvdWQtY29uZmlnOiB7fQ==" # Base64 encoded empty cloud-config
  node = var.controlplane_ips[count.index]
  endpoint = var.controlplane_ips[0]
  config_patches = [local.cilium_patches]
  config_patch_format = "json-6902" # RFC6902 JSON Patch format
}

# Diese Ressource stellt die Cilium-Konfiguration für Worker-Nodes bereit
resource "talos_machine_configuration_apply" "worker_cilium" {
  count = var.machine_config_target == "worker" || var.machine_config_target == "all" ? length(var.worker_ips) : 0

  client_configuration = jsondecode(var.talos_client_configuration)
  machine_configuration_input = "Y2xvdWQtY29uZmlnOiB7fQ==" # Base64 encoded empty cloud-config
  node = var.worker_ips[count.index]
  endpoint = var.controlplane_ips[0]
  config_patches = [local.cilium_patches]
  config_patch_format = "json-6902" # RFC6902 JSON Patch format
}
