#Create Security Groups
resource "aws_security_group" "tc_alb_secg" {
    vpc_id      = aws_vpc.vpc.id
    name = "tc_alb_secg"
    description = "TechChallenge ALB Group"
    ingress {
        from_port       = 3000
        to_port         = 3000
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "tc_rds_secg" {
    vpc_id      = aws_vpc.vpc.id
    name = "tc_rds_secg"
    description = "TechChallenge RDS Security Group"
    ingress {
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        cidr_blocks     = ["10.10.0.0/21"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
