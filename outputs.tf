output "autoscaling_groups" {
  value = [for a in aws_autoscaling_group.nat_asg : a.id]
}

output "nat_eni_interfaces" {
  value = [for e in aws_network_interface.nat_eni : e.id]
}
