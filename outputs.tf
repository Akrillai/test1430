
output "builder_ip_name" {
  value = aws_instance.builder_instance.public_ip
  description = "IP of the Builder"
}

output "webserver_ip_name" {
  value = aws_instance.webserver_instance.public_ip
  description = "IP of the Webserver"
}