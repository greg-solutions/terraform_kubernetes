resource "kubernetes_namespace" "namespace" {
  count = "${length(var.namespaces)}"
  metadata {
    name = "${element(var.namespaces,count.index )}"
  }
}

module "aws_ebs" {
  source = "modules/storages/aws/ebs"
}
module "aws_efs" {
  source = "modules/storages/aws/efs"
  security_group_ids = ["sg-03678c23c8fb550ca"]
  subnets_ids = [
    "subnet-05dc362e868d946e6"]
}

module "mongo" {
  source = "modules/mongodb"
}