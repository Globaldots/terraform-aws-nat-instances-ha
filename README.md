# this module is based on [tf_aws_nat](https://github.com/terraform-community-modules/tf_aws_nat)

## Module to launch NAT instances on AWS.

This module provisions HA NAT service by launching autoscaling groups with NAT instances in the specified public subnets to allow
outbound internet traffic from the private subnets. For route publishing and High Availability
each instance runs the [AWSnycast](https://github.com/bobtfish/AWSnycast) service. If the nat
instance becomes unavailable it will remove the instance from the route table (this requires
at least 2 instances). NAT instances are an alternative to NAT Gateways to determine which one
is best for your use case please see the following:

* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-comparison.html
* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html
* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html

Auto-healing is achieved with the help of autoscaling group: if one NAT instance has been terminated,
ASG spins up a new one attaching proper ENI. 

## Inputs
    
  * `name` - Name prefix for resources (defaults to "default")
  * `ami_name_pattern` - The regex to filter which ami used (defaults to Ubuntu 20.04)
  * `ami_publisher` - The ami publisher id (defaults to Canonical's)
  * `instance_type` - The type of instance to provision (defaults to "t3a.micro")
  * `public_subnet_ids` - A list of the public subnets to provision in (required)
  * `private_subnet_ids` - A list of the private subnets to allow traffic from (required)
  * `vpc_security_group_ids` - A list of security groups applied to the nat eni interfaces (required)
  * `aws_key_name` - The name of the AWS key pair to provision the instances with
  * `tags` - A map of tags to apply to resources
  * `route_table_identifier` - The identifier used in the route table regexp used by AWSnycast (defaults to "private" for  terraform-aws-vpc module compatibility)
  * `awsnycast_deb_url` - The url of AWSnycast deb package
  * `poll_time` -  "AWS route tables poll rate in seconds (defaults to 30)"

## Outputs

  * `autoscaling_groups` - A list of the autoscaling groups
  * `nat_eni_interfaces` - A list of the nat eni interfaces

## Usage
```hcl
resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow nat traffic"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

module "nat" {
  source = "github.com/Globaldots/terraform-aws-nat-instances-ha"

  name = module.vpc.name

  aws_key_name = module.key_pair.this_key_pair_key_name

  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  vpc_security_group_ids = [aws_security_group.nat.id]
}

```

## Authors

Module managed by [Yurii Polishchuk](https://github.com/yuriipolishchuk).

# License

Apache2, see the included LICENSE file for more information.
