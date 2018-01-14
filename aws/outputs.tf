output "server_address" {
    value = "http://${aws_instance.vagabond_lnx.*.public_dns}:8000/ps/signon.html"
}
