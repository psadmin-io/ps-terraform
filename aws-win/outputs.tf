output "server_address" {
    value = "http://${aws_instance.vagabond_win.*.public_dns}:8000/ps/signon.html"
}
