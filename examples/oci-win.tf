# oci-win Example
terraform {
  required_version = ">= 0.12"
}

provider "oci" { 
  version              = ">= 3.0.0"
  region               = "<TODO>"
  tenancy_ocid         = "<TODO>"
  user_ocid            = "<TODO>"
  fingerprint          = "<TODO>"
  private_key_path     = "<TODO>"
  private_key_password = "<TODO>"
}

module "ps-terraform" {
  # module source location, if not using published version
  source             = "c:/repos/ps-terraform"
  oci-win_count      = "1" 

  ad                 = "<TODO>"
  compartment_id     = "<TODO>"
  subnet_id          = "<TODO>"
  image_id           = "<TODO>"
  mos_username       = "<TODO>"
  mos_password       = "<TODO>"
  patch_id           = "<TODO>"
}