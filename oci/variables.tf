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

variable "availability_domain" {
  description = "Availablility Domain for the Region"
  default = "IAD-AD-1"
}

variable "oci_name" {
  description = "Common name to use for OCI components"
}

variable "compartment_description" {
  description = "Description of OCI Compartment"
}

variable "group_description" {
  description = "OCI Tenancy Group Description"
}

variable "policy_description" {
  description = "OCI Group Policy Description"
}

variable "policy_statements" {
  type = "list"
  description = "Access for a policy"
}

variable "user_description" {
  description = "OCI User Description"
}

variable "api_key_key_value" {
  description = "API Public Key"
}

# Networking
variable "http_port" {
  description = "HTTP Port Number"
  default = "8000"
}