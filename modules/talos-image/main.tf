data "talos_image_factory_versions" "this" {}

locals {
  stable_versions = [for v in data.talos_image_factory_versions.this.talos_versions : v if !strcontains(v, "-")]
  highest_stable_version = length(local.stable_versions) > 0 ? local.stable_versions[length(local.stable_versions) - 1] : ""
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.highest_stable_version
  filters = {
    names = [
      "qemu-guest-agent"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  schematic_id  = talos_image_factory_schematic.this.id
  talos_version = local.highest_stable_version
  platform = var.platform
}

# Temporäres Verzeichnis für das Entpacken des ZST-Archivs
resource "local_file" "temp_directory" {
  content  = ""
  filename = "${path.module}/tmp/.placeholder"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/tmp"
  }
}

# Herunterladen und Entpacken des Talos Disk-Images
resource "null_resource" "download_and_extract_disk_image" {
  depends_on = [local_file.temp_directory]

  # Neuberechnung erzwingen, wenn sich die URL ändert
  triggers = {
    image_url = data.talos_image_factory_urls.this.urls.disk_image
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      curl -L ${data.talos_image_factory_urls.this.urls.disk_image} -o ${path.module}/tmp/talos-disk.zst
      zstd -df ${path.module}/tmp/talos-disk.zst
      qemu-img convert -f raw -O qcow2 ${path.module}/tmp/talos-disk ${path.module}/tmp/talos-disk.qcow2
      mv ${path.module}/tmp/talos-disk.qcow2 ${path.module}/tmp/talos-disk
    EOT
  }
}

# Talos Disk-Image als Volume registrieren
resource "libvirt_volume" "talos_disk_image" {
  name   = "talos-base-${local.highest_stable_version}.qcow2"
  pool   = var.pool
  source = "${path.module}/tmp/talos-disk"
  format = "qcow2"

  depends_on = [null_resource.download_and_extract_disk_image]
}

# Temporäre Dateien nach der Erstellung des Volumes aufräumen
resource "null_resource" "cleanup_temp_files" {
  depends_on = [libvirt_volume.talos_disk_image]

  # Trigger Cleanup immer, wenn sich das Volume ändert
  triggers = {
    volume_id = libvirt_volume.talos_disk_image.id
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/tmp"
  }
}
