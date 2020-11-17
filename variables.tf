variable "name" {
  type    = string
  default = "default"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

variable "ami_name_pattern" {
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  description = "The name filter to use in data.aws_ami"
}

variable "ami_publisher" {
  default     = "099720109477" # Canonical
  description = "The AWS account ID of the AMI publisher"
}

variable "instance_type" {
  type    = string
  default = "t3a.micro"
}

variable "public_subnet_ids" {
  type = list(string)

  validation {
    condition = (
      length(var.public_subnet_ids) >= 2
    )
    error_message = "At least 2 public subnets must be provided for HA."
  }
}

variable "private_subnet_ids" {
  type = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) >= 2
    )
    error_message = "At least 2 private subnets must be provided for HA."
  }
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "aws_key_name" {
  type    = string
  default = ""
}

variable "awsnycast_deb_url" {
  type    = string
  default = "https://github.com/Globaldots/AWSnycast/releases/download/v0.2.2/awsnycast_0.2.2-0_amd64.deb"
}

variable "route_table_identifier" {
  description = "Indentifier used by AWSnycast route table regexp"
  default     = "private"
}

variable "poll_time" {
  type        = number
  description = "AWS route tables poll rate"
  default     = 30
}
