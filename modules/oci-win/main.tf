locals { # TODO - move these files to sub-module level, not base?
    scripts_dir     = "${path.module}/../../files/scripts"
    config_dir     = "${path.module}/../../files/config"
    templates_dir = "${path.module}/../../files/templates"
}

data "oci_core_subnet" "main" {
  subnet_id = var.subnet_id
}

data "template_file" "user_data" {
  count    = var.oci-win_count
  template = file("${local.templates_dir}/user_data_win.cfg")

  vars = {
    admin_user = var.admin_user
    admin_pass = var.admin_pass
    hostname   = var.hostname
    dns_label  = data.oci_core_subnet.main.dns_label
    ip         = "127.0.0.1" #TODO
  }
}

resource oci_core_instance "instance" {  
    count               = var.oci-win_count
    availability_domain = var.ad
    compartment_id      = var.compartment_id  
    display_name        = var.hostname
    shape               = var.shape

    source_details {                    
        source_id   = var.image_id
        source_type = var.image_type
    }

	  create_vnic_details {                
		  hostname_label   = var.hostname
		  subnet_id        = data.oci_core_subnet.main.id
	  }    

    metadata = {
        user_data = base64encode(element(data.template_file.user_data.*.rendered, count.index)) ,
    }    
      
    timeouts {
        create = "60m"
    }    

    freeform_tags  = { 
        name = "ps-terraform" #TODO var.tag_name
    }
}

resource "null_resource" "instance_provision" {
    count = var.oci-win_count
    depends_on = [ oci_core_instance.instance ] 

    connection {
        type     = "winrm"
        user     = var.admin_user
        password = var.admin_pass
        host     = element(oci_core_instance.instance.*.public_ip, count.index)
        
        timeout = "30s"
    }

  provisioner "file" {
    source      = "${local.config_dir}/psft_customizations-win.yaml"
    destination = "c:/vagrant/config/psft_customizations.yaml"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/vagabond.json"
    destination = "C:/vagrant/scripts/vagabond.json"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/banner.ps1"
    destination = "c:/temp/banner.ps1"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/provision-download.ps1"
    destination = "c:/temp/provision-download.ps1"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/provision-bootstrap-ps.ps1"
    destination = "c:/temp/provision-bootstrap-ps.ps1"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/provision-yaml.ps1"
    destination = "c:/temp/provision-yaml.ps1"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/provision-puppet-apply.ps1"
    destination = "c:/temp/provision-puppet-apply.ps1"
  }
  provisioner "file" {
    source      = "${local.scripts_dir}/win/provision-utilities.ps1"
    destination = "c:/temp/provision-utilities.ps1"
  }
  
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -File C:\\temp\\banner.ps1",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -Command 'New-Item -ItemType directory -Path c:/psft/dpk/downloads'",
      "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-download.ps1 -MOS_USERNAME ${var.mos_username} -MOS_PASSWORD ${var.mos_password} -PATCH_ID ${var.patch_id} -DPK_INSTALL c:/psft/dpk/download/${var.patch_id}",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-bootstrap-ps.ps1 -PATCH_ID ${var.patch_id} -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-yaml.ps1 -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-puppet-apply.ps1 -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-puppet-utilities.ps1",
    ]
  }
}

resource "oci_core_security_list" "ps-terraform-win" {
  count          = var.oci-win_count
  compartment_id = var.compartment_id   
  display_name   = "ps-terraform" # TODO platform and tag?
  vcn_id         = data.oci_core_subnet.main.vcn_id
	
  # outbound
  egress_security_rules {
    protocol    = "6" # tcp
    destination = "0.0.0.0/0"
  }

  # inbound
  ingress_security_rules {
    description = "RDP"    
    protocol  = "6" # tcp
    source    = "0.0.0.0/0" # TODO - var
    stateless = false   

    tcp_options {
      max = "3389"  
      min = "3389"
    }
  }

  ingress_security_rules {   
    description = "WinRM"    
    protocol  = "6" # tcp
    source    = "0.0.0.0/0" # TODO - var
    stateless = false 
    
    tcp_options {
      min = "5985" 
      max = "5986"
    }
  }

  # ingress_security_rules { 
  #   description = "PIA"   
  #   protocol    = "6" # tcp
  #   source      = "0.0.0.0/0"    
  #   stateless   = false 
    
  #   tcp_options {
  #     min = "80"
  #     max = "80"
  #   }
  # }

  ingress_security_rules { 
    description = "PIA"   
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"   # TODO - var  
    stateless   = false 
    
    tcp_options {
      min = "8000"
      max = "8000"
    }
  }

  ingress_security_rules { 
    description = "SSH"   
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"    # TODO - var 
    stateless   = false 
    
    tcp_options {
      min = "22"
      max = "22"
    }
  }

  ingress_security_rules { 
    description = "Database"   
    protocol    = "6" # tcp
    source      = "0.0.0.0/0"     # TODO - var
    stateless   = false 
    
    tcp_options {
      min = "1521"
      max = "1522"
    }
  }
}