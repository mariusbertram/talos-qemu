# Erstellt ein Volume für jeden Node basierend auf dem Talos Basis-Image
resource "libvirt_volume" "node_disk" {
  name           = "${var.name_prefix}-${count.index}.qcow2"
  base_volume_id = var.talos_base_volume_id
  count          = var.node_count
  pool           = var.pool
  size           = var.disk_size
  format         = "qcow2"
}

# Erstellt die VMs mit dem Talos-Disk-Image
resource "libvirt_domain" "node" {
  name       = "${var.name_prefix}-${count.index}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.node_count
  qemu_agent = true

  # Direkt von der Festplatte booten, kein CD-ROM mehr nötig
  boot_device {
    dev = ["hd"]
  }

  network_interface {
    network_name   = var.network_name
    hostname       = "${var.name_prefix}-${count.index}"
    addresses      = ["${var.ip_prefix}${count.index}"]
    wait_for_lease = true
  }

  # Nur ein Disk für Talos (kein ISO mehr nötig)
  disk {
    volume_id = libvirt_volume.node_disk[count.index].id
  }

  cpu {
    mode = "host-passthrough"
  }

  # Wichtige Flags für Talos
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  # OVMF für UEFI Boot benötigt
  xml {
    xslt = <<-XSLT
      <?xml version="1.0" ?>
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output omit-xml-declaration="yes" indent="yes"/>
        <xsl:template match="node()|@*">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
          </xsl:copy>
        </xsl:template>
        <xsl:template match="/domain/features">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <acpi/>
            <apic/>
          </xsl:copy>
        </xsl:template>
      </xsl:stylesheet>
    XSLT
  }
}
