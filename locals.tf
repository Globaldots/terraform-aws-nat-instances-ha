locals {
  # Build a map with public subnets ids as keys and private subnet ids as values
  # to use appropriate values for route tables
  public_to_private_subnets_mapping = {
    for p in setproduct(var.public_subnet_ids, var.private_subnet_ids) : p[0] => p[1]

    # private and public subnets must be in the same AZ
    if data.aws_subnet.subnets[p[0]].availability_zone == data.aws_subnet.subnets[p[1]].availability_zone
  }
}
