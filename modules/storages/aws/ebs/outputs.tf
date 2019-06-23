output "volume_name" {
  value = "${kubernetes_storage_class.ebs_storage.metadata.name}"
}