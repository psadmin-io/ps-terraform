output "server_address" {
    value = "http://${aws_instance.vagabond-win.0.public_dns}:8000/ps/signon.html"
}
