output "public_ips" {
  value = oci_core_instance.instance.*.public_ip
}
