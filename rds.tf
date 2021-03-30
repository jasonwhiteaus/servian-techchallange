# Create DB Password
resource "random_password" "password" {
  length           = 15
  special          = false
  override_special = "/_%@ "  
}


resource "aws_db_subnet_group" "tc_rds_subnet_grp" {
  name       = "tc_rds_subnet_grp"
  subnet_ids = toset(aws_subnet.tc_public_subnet_group.*.id)
}

#Create Database
resource "aws_db_instance" "tc_rds_db" {
  allocated_storage       = 20
  identifier              = "techchallenge-db"
  engine                  = "postgres"
  engine_version          = "12.5"
  instance_class          = "db.t2.micro"
  parameter_group_name    = "default.postgres12"
  name                    = var.tc_dbname
  username                = var.tc_dbusername
  password                = aws_ssm_parameter.tc_ssm_dbpass.value
  vpc_security_group_ids  = [aws_security_group.tc_rds_secg.id]
  multi_az                = var.tc_rds_multiazdeployment
  db_subnet_group_name    = aws_db_subnet_group.tc_rds_subnet_grp.id
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
}

