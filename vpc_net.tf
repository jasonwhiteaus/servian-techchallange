# Create Network
data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
    cidr_block = "10.10.0.0/21"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "TechChallenge-VPC"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    
    tags = {
      Name = "TechChallengeInternetGW"
    }
}

resource "aws_subnet" "tc_public_subnet_group" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.10.${count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
      Name = "TechChallenge-Subnet-${count.index}"
  }
}

resource "aws_route_table" "tc_routetable" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    tags = {
        Name = "TechChallengeRouteTable"
    }
}

resource "aws_route_table_association" "tc_routeassociation" {
    count = "${length(aws_subnet.tc_public_subnet_group)}"
    subnet_id      = aws_subnet.tc_public_subnet_group[count.index].id
    route_table_id = aws_route_table.tc_routetable.id
}

