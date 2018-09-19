# Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

resource "oci_identity_compartment" "sandbox_compartment" {
	#Required
	compartment_id = "${var.tenancy_ocid}"
	description = "${var.compartment_description}"
	name = "${var.compartment_name}"

	#Optional
	defined_tags = {"Operations.CostCenter"= "42"}
	freeform_tags = {"Department"= "Finance"}
}