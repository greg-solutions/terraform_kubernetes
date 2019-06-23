resource "kubernetes_storage_class" "efs_storage" {
  metadata {
    name = "ebs-storage"
  }
  storage_provisioner = "kubernetes.io/aws-efs"

  parameters {
    type = "gp2"
    fsType="ext4"
  }
}