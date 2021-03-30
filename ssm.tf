resource "aws_ssm_parameter" "tc_ssm_dbpass" {
  name        = var.tc_ssm_keylocation
  description = "TechChallenge RDS Database Password"
  type        = "SecureString"
  value       = random_password.password.result
}

