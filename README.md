# Talos Kubernetes Cluster auf Libvirt

Dieses Terraform-Projekt erstellt einen Talos-basierten Kubernetes-Cluster auf Libvirt mit folgenden Komponenten:

- Talos Linux als Betriebssystem für alle Nodes
- Libvirt als Virtualisierungsplattform
- Cilium als CNI (Container Network Interface)
- Konfiguration und Bootstrapping des Talos-Clusters

## Voraussetzungen

- Libvirt installiert und konfiguriert
- Terraform installiert
- SSH-Zugriff auf den Libvirt-Host
- UEFI-Firmware für Libvirt (/usr/share/OVMF/OVMF_CODE.fd)

## Struktur

Das Projekt ist in mehrere Module unterteilt:

- **talos-image**: Lädt und konfiguriert das Talos-Disk-Image aus der Talos Image Factory
- **libvirt-network**: Erstellt das Netzwerk für den Cluster
- **talos-node**: Erstellt die virtuellen Maschinen für Controlplane und Worker Nodes
- **talos-cluster**: Konfiguriert und bootstrapt den Talos-Cluster mit Cilium als CNI

## Templates

Alle Template-Dateien für die Konfiguration befinden sich im `files/` Verzeichnis:

- `cilium-values.yaml`: Helm-Werte für die Cilium-Installation
- `controlplane-patch.yaml`: Konfigurationspatch für die Controlplane-Nodes
- `worker-patch.yaml`: Konfigurationspatch für die Worker-Nodes

## Verwendung

1. Terraform initialisieren:

```bash
terraform init
```

2. Die Konfiguration anpassen (optional):

```bash
cp terraform.tfvars.example terraform.tfvars
# Passen Sie die Werte in terraform.tfvars an
```

3. Plan erstellen und anwenden:

```bash
terraform plan
terraform apply
```

4. Nach erfolgreicher Erstellung die Kubeconfig abrufen:

```bash
terraform output -raw kubeconfig > ~/.kube/config
```

5. Talosconfig für den Zugriff auf die Talos-API abrufen:

```bash
terraform output -raw talosconfig > ~/.talos/config
```

## Hauptvariablen

| Variable | Beschreibung | Standard |
|----------|-------------|----------|
| `controlplane` | Anzahl der Control-Plane-Nodes | 3 |
| `worker` | Anzahl der Worker-Nodes | 3 |
| `libvirt_uri` | URI des Libvirt-Providers | qemu+ssh://marius@fedora.fritz.box/system |
| `libvirt_pool` | Storage-Pool für die VM-Festplatten | default |
| `cluster_name` | Name des Kubernetes-Clusters | talos-k8s |
| `controlplane_endpoint` | VIP für die Kontrollebene | 192.168.100.100 |
| `network_cidr` | CIDR des Netzwerks | 192.168.100.0/24 |
| `cilium_version` | Version von Cilium | v1.17.4 |

## Outputs

- `disk_image_url`: URL des Talos Disk-Images
- `highest_stable_version`: Verwendete Talos-Version
- `controlplane_ips`: IP-Adressen der Control-Plane-Nodes
- `worker_ips`: IP-Adressen der Worker-Nodes
- `kubeconfig`: Kubeconfig für den Zugriff auf den Kubernetes-Cluster
- `talosconfig`: Talosconfig für den Zugriff auf den Talos-Cluster
- `cluster_endpoint`: Endpunkt des Kubernetes-Clusters
