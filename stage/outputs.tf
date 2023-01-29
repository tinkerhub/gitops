output "reverse_proxy_listener_arn" {
value = {
	"http" = aws_lb_listener.http.arn,
	"https" = aws_lb_listener.https.arn,
}
} 

output "reverse_proxy_alb_dns_name" {
	value = aws_lb.reverse_proxy.dns_name
}
