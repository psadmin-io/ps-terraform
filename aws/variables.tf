variable "platform" {
  default     = "rhel7"
  description = "The OS Platform"
}

variable "user" {
  default = {
    rhel7   = "ec2-user"
  }
}

variable "ami" {
  description = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "

  default = {
    us-east-1-rhel7       = "ami-2051294a"
    us-east-2-rhel7       = "ami-0a33696f"
    us-west-2-rhel7       = "ami-775e4f16"
  }
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "key_path" {
  description = "Path to the private key specified by key_name."
}

variable "region" {
  default     = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "servers" {
  default     = "1"
  description = "The number of PeopleSoft Image servers to launch."
}

variable "instance_type" {
  default     = "m4.large" # 2 CPU, 8GB RAM, Moderate performance
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "tagName" {
  default     = "PeopleSoft Image"
  description = "Name tag for the servers"
}

variable "mos_username" {
  description = "My Oracle Support Username"
}

variable "mos_password" {
  description = "My Oracle Support Password"
}

variable "patch_id" {
  description = "My Oracle Support Patch Number for the PeopleSoft Image"
}

variable "dpk_install" {
  description = "Folder on VM where the DPK will download"
}