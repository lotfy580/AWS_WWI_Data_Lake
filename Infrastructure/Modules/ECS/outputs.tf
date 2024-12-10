output "lb_url" {
  value = "http://${aws_lb.lb.dns_name}:${aws_lb_listener.lb_listener.port}"
}
