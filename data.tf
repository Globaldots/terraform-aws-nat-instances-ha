data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_publisher]
}


data "aws_subnet" "subnets" {
  for_each = toset(concat(var.private_subnet_ids, var.public_subnet_ids))

  id = each.value
}


data "template_file" "user_data" {
  for_each = toset(var.private_subnet_ids)

  template = file("${path.module}/nat-user-data.conf.tmpl")

  vars = {
    name              = var.name
    mysubnet          = each.value
    vpc_cidr          = data.aws_vpc.vpc.cidr_block
    region            = data.aws_region.current.name
    awsnycast_deb_url = var.awsnycast_deb_url
    identifier        = var.route_table_identifier
    poll_time         = var.poll_time
  }
}


data "aws_subnet" "first" {
  id = var.public_subnet_ids[0]
}


data "aws_vpc" "vpc" {
  id = data.aws_subnet.first.vpc_id
}


data "aws_region" "current" {}


data "aws_subnet" "nat_eni_subnet" {
  for_each = aws_network_interface.nat_eni

  id = each.value.subnet_id
}
