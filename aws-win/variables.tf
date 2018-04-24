variable "platform" {
  default     = "win2016"
  description = "The OS Platform"
}

variable "machine_name" {
  description   = "Server name"
}

variable "user" {
  default = {
    win2016   = "Administrator"
  }
}

variable "ami" {
  description = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "
  default = "ami-2b6f3c51" # AWS Windows 2016 Base
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
  default     = "t2.large" # 2 CPU, 8GB RAM, Moderate performance
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

variable "admin_password" {
  default = "SomeThingMoreS3cur#"
  description = "Windows Administrator password"
}
