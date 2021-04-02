<!-- markdownlint-disable -->
[![GitHub Action Tests](https://img.shields.io/github/workflow/status/Globaldots/terraform-aws-nat-instances-ha/Terraform?label=tests)](https://github.com/Globaldots/terraform-aws-nat-instances-ha/actions) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/globaldots/terraform-aws-nat-instances-ha)
<!-- markdownlint-restore -->

# terraform-aws-nat-instances-ha - Terraform Module to provision NAT instances on AWS

## this module is based on [tf_aws_nat](https://github.com/terraform-community-modules/tf_aws_nat)


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


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.5 |
| aws | >= 3.22.0 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.22.0 |
| template | >= 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_name\_pattern | The name filter to use in data.aws\_ami | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_publisher | The AWS account ID of the AMI publisher | `string` | `"099720109477"` | no |
| aws\_key\_name | n/a | `string` | `""` | no |
| awsnycast\_deb\_url | n/a | `string` | `"https://github.com/Globaldots/AWSnycast/releases/download/v0.2.2/awsnycast_0.2.2-0_amd64.deb"` | no |
| instance\_type | n/a | `string` | `"t3a.micro"` | no |
| name | n/a | `string` | `"default"` | no |
| poll\_time | AWS route tables poll rate | `number` | `30` | no |
| private\_subnet\_ids | n/a | `list(string)` | n/a | yes |
| public\_subnet\_ids | n/a | `list(string)` | n/a | yes |
| route\_table\_identifier | Indentifier used by AWSnycast route table regexp | `string` | `"private"` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| vpc\_security\_group\_ids | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_groups | n/a |
| nat\_eni\_interfaces | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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
