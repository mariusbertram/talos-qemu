#!/bin/bash
set -e

# Dieses Skript hilft beim Einrichten der kubectl-Konfiguration

KUBECONFIG_PATH="$(pwd)/output/kubeconfig"
TALOSCONFIG_PATH="$(pwd)/output/talosconfig"

if [ ! -f "$KUBECONFIG_PATH" ]; then
  echo "Fehler: Kubeconfig wurde nicht gefunden in $KUBECONFIG_PATH"
  echo "Bitte führen Sie zuerst 'terraform apply' aus."
  exit 1
fi

if [ ! -f "$TALOSCONFIG_PATH" ]; then
  echo "Fehler: Talosconfig wurde nicht gefunden in $TALOSCONFIG_PATH"
  echo "Bitte führen Sie zuerst 'terraform apply' aus."
  exit 1
fi

# Mache das Skript ausführbar
chmod +x "$0"

# Stelle sicher, dass kubectl installiert ist
if ! command -v kubectl &> /dev/null; then
  echo "kubectl konnte nicht gefunden werden. Bitte installieren Sie kubectl."
  exit 1
fi

# Stelle sicher, dass talosctl installiert ist
if ! command -v talosctl &> /dev/null; then
  echo "talosctl konnte nicht gefunden werden. Bitte installieren Sie talosctl."
  exit 1
fi

# Exportiere Umgebungsvariablen
echo "\nFügen Sie die folgenden Zeilen zu Ihrer Shell-Konfiguration hinzu oder führen Sie sie aus:\n"
echo "export KUBECONFIG=$KUBECONFIG_PATH"
echo "export TALOSCONFIG=$TALOSCONFIG_PATH"

# Test-Verbindung
echo "\nTeste Verbindung zum Cluster..."
export KUBECONFIG=$KUBECONFIG_PATH
export TALOSCONFIG=$TALOSCONFIG_PATH

kubectl get nodes
echo "\nTalos-Nodes prüfen:"
talosctl version

echo "\nSetup abgeschlossen!"
