resource "aws_efs_file_system" "efs_provisioner" {
  tags {
    Name = "efs.k8s.local"
  }
  performance_mode = "generalPurpose"
}

resource "aws_efs_mount_target" "efs_provisioner" {
  count = "${length(var.subnets_ids)}"
  file_system_id = "${aws_efs_file_system.efs_provisioner.id}"
  subnet_id = "${var.subnets_ids[count.index]}"
  security_groups = [
    "${var.security_group_ids}"]
}

resource "kubernetes_persistent_volume" "efs" {
  metadata {
    name = "efs-pv"
  }
  spec {
    capacity {
      storage = "2Gi"
    }

    access_modes = [
      "ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path = "/"
        server = "${aws_efs_mount_target.efs_provisioner.dns_name}"
      }

    }
  }
}