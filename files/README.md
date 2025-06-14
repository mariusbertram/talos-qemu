# Talos Cluster Template-Dateien

Dieses Verzeichnis enthält die Template-Dateien für die Konfiguration des Talos-Clusters.

## Dateien

- `cilium-values.yaml`: Helm-Werte für die Cilium-Installation
- `controlplane-patch.yaml`: Konfigurationspatch für die Controlplane-Nodes
- `worker-patch.yaml`: Konfigurationspatch für die Worker-Nodes

## Variablen

Die Template-Dateien verwenden die folgenden Variablen:

- `${cluster_name}`: Name des Kubernetes-Clusters
- `${hostname}`: Hostname der Node
- `${controlplane_endpoint}`: VIP für die Kontrollebene
- `${network_cidr}`: CIDR des Netzwerks
- `${cilium_version}`: Version von Cilium
- `${cilium_values}`: Konfigurationswerte für Cilium
