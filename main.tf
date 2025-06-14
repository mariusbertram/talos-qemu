# Talos Image erstellen
module "talos_image" {
  source = "./modules/talos-image"

  providers = {
    libvirt = libvirt
    talos   = talos
  }
}

# Netzwerk erstellen
module "network" {
  source = "./modules/libvirt-network"

  network_name = "private-backend"
  domain       = "k8s.local"
  addresses    = [var.network_cidr]

  providers = {
    libvirt = libvirt
  }
}

# Control-Plane-Nodes erstellen
module "controlplane" {
  source = "./modules/talos-node"

  name_prefix        = "controlplane"
  node_count         = var.controlplane
  network_name       = module.network.network_name
  ip_prefix          = "192.168.100.1"
  talos_base_volume_id = module.talos_image.talos_base_volume_id
  pool               = var.libvirt_pool

  providers = {
    libvirt = libvirt
  }
}

# Worker-Nodes erstellen
module "worker" {
  source = "./modules/talos-node"

  name_prefix        = "worker"
  node_count         = var.worker
  network_name       = module.network.network_name
  ip_prefix          = "192.168.100.2"
  talos_base_volume_id = module.talos_image.talos_base_volume_id
  pool               = var.libvirt_pool

  providers = {
    libvirt = libvirt
  }
}

# Talos-Cluster konfigurieren und bootstrappen
module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster_name          = var.cluster_name
  controlplane_endpoint = var.controlplane_endpoint
  controlplane_ips      = module.controlplane.ip_addresses
  worker_ips            = module.worker.ip_addresses
  network_cidr          = var.network_cidr

  providers = {
    talos = talos
  }

  # Warte auf die VMs, bevor der Cluster konfiguriert wird
  depends_on = [
    module.controlplane,
    module.worker
  ]
}

# Stelle sicher, dass der Output-Ordner existiert
resource "null_resource" "ensure_output_dir" {
  provisioner "local-exec" {
    command = "mkdir -p output"
  }
}

# Speichere Kubeconfig in eine Datei
resource "local_sensitive_file" "kubeconfig" {
  content           = module.talos_cluster.kubeconfig
  filename          = "output/kubeconfig"
  file_permission   = "0600"

  depends_on = [null_resource.ensure_output_dir]
}

# Speichere Talosconfig in eine Datei
resource "local_sensitive_file" "talosconfig" {
  content           = module.talos_cluster.talosconfig_raw
  filename          = "output/talosconfig"
  file_permission   = "0600"

  depends_on = [null_resource.ensure_output_dir]
}