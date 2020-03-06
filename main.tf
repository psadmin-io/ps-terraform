module "oci-win" {
  source             = "./modules/oci-win" 
  oci-win_count      = var.oci-win_count
  admin_user         = var.admin_user
  admin_pass         = var.admin_pass
  compartment_id     = var.compartment_id
  subnet_id          = var.subnet_id
  ad                 = var.ad
  image_id           = var.image_id
  mos_username       = var.mos_username
  mos_password       = var.mos_password
  mos_patch_id       = var.mos_patch_id
}