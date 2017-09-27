output "server_address" {
    value = "http://${aws_instance.server.0.public_dns}:8000/ps/signon.html"
}
