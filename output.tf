output "instance_public_ip" {
  value = "${aws_instance.webserver_1.public_ip}"
}

output "lb_url" {
  value = "${aws_lb.web_lb.dns_name}"
}