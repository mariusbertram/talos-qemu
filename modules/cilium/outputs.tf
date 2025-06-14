output "cilium_patch" {
  value       = local.cilium_patches
  description = "Der fertige Patch für die Cilium-Installation im RFC6902 Format"
}
