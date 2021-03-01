# Provision one ENI per each provided public subnet
resource "aws_network_interface" "nat_eni" {
  for_each = toset(var.public_subnet_ids)

  subnet_id         = each.value
  security_groups   = var.vpc_security_group_ids
  source_dest_check = false
}


resource "aws_launch_template" "launch_template" {
  for_each = aws_network_interface.nat_eni

  name_prefix = format("%s-nat-instance-%s", var.name, each.value.subnet_id)

  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.nat_profile.arn
  }

  user_data = base64encode(data.template_file.user_data[local.public_to_private_subnets_mapping[each.key]].rendered)

  key_name = var.aws_key_name

  network_interfaces {
    delete_on_termination = false
    network_interface_id  = each.value.id
  }

  credit_specification {
    cpu_credits = "standard" # for T2/T3 instances to avoid extra costs
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = format("%s-nat-instance-%s", var.name, data.aws_subnet.subnets[each.key].availability_zone)
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "nat_asg" {
  for_each = aws_launch_template.launch_template

  # One instance per subnet
  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  launch_template {
    id      = each.value.id
    version = each.value.latest_version
  }

  # https://github.com/hashicorp/terraform-provider-aws/pull/7615
  availability_zones = [data.aws_subnet.nat_eni_subnet[each.key].availability_zone]
}
