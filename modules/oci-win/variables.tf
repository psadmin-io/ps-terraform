variable "oci-win_count" {
    description = "The number of OCI Win instances."
    default = "0"
}

variable "compartment_id" {
    description = "Compartment ID."
}

variable "subnet_id" {
    description = "Subnet ID."
}

variable "hostname" {
    default = "ps-terraform"
    description = "Client Tools instance hostname"
}

variable "shape" {
  default = "VM.Standard2.1"
  description = "Client Tools instance shape"
}

variable "ad" { 
  description = "Availability Domain"
}

variable "image_id" {
    description = "The instance source id used for the Client Tools instance."
}

variable "image_type" {
    default = "image"
    description = "The instance source type used for the Client Tools instance."
}

variable "admin_user" {
    description = "The admin user for the Client Tools instance."
    default = "opc"
}

variable "admin_pass" {
    description = "The admin password for the Client Tools instance."
}

variable "mos_username" {
  description = "My Oracle Support Username"
}

variable "mos_password" {
  description = "My Oracle Support Password"
}

variable "mos_patch_id" {
  description = "My Oracle Support Patch Number for the PeopleSoft Image"
}