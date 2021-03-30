output "tc_alb_url" {
  value = join("", ["http://",aws_lb.tc_alb.dns_name ,":3000/"])
  sensitive = false
}

output "tc_db_password" {
  value = aws_db_instance.tc_rds_db.password
  sensitive = false
}