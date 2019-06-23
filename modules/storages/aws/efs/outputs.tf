output "efs_provisoner_fsid" {
  value = "${aws_efs_file_system.efs_provisioner.id}"
}
output "efs_provisoner_dns" {
  value = "${aws_efs_file_system.efs_provisioner.dns_name}"
}