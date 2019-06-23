resource "kubernetes_storage_class" "ebs_storage" {
  metadata {
    name = "ebs-storage"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"

  parameters {
    type = "gp2"
    fsType="ext4"
  }
}