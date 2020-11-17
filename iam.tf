resource "aws_iam_instance_profile" "nat_profile" {
  name = "${var.name}-nat_ha_profile"
  role = aws_iam_role.role.name
}


resource "aws_iam_role" "role" {
  name = "${var.name}-nat_ha_role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    effect = "Allow"
  }
}


data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:ReplaceRoute",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DescribeRouteTables",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "modify_routes" {
  name = "nat_ha_modify_routes"
  role = aws_iam_role.role.id

  policy = data.aws_iam_policy_document.policy.json
}

