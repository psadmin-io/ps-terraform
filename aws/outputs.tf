output "server_address" {
    value = "http://${aws_instance.vagabond-lnx.*.public_dns}:8000/ps/signon.html"
}
