# output "server_address" {
#     value = ["http://${aws_instance.vagabond_win.*.public_dns}:8000/ps/signon.html"]
# }

# output "public_ips" {
#   count = "${var.servers}"
#   value = ["${element(aws_instance.vagabond_win.*.public_ip, count.index)}"]
# }
