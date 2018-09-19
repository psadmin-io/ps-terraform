variable "tenancy_ocid" {
  description = "Tenancy OCID"
}

variable "user_ocid" {
  description = "User OCID"
}

variable "fingerprint" {
  description = "Private Key Fingerprint"
}

variable "private_key_path" {
  description = "Private Key Path"
}

variable "region"{
  default = "us-ashburn-1"
  description = "OCI Region"
}