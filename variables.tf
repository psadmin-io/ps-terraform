variable "oci-win_count" {
    description = "The number of OCI Win instances."
    default = "0"
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

variable "admin_user" {
    description = "The admin user for the Client Tools instance."
    default = "opc"
}

variable "admin_pass" {
    default = "touch46?S!nk"
    description = "The admin password for the Client Tools instance."
}

variable "compartment_id" {
    description = "Compartment ID."
}

variable "subnet_id" {
    description = "Subnet ID."
}

variable "ad" {
    description = "Available domain."
}

variable "image_id" {
    description = "Image id."
}

