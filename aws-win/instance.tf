provider "aws" {
  region     = "${var.region}"
}

data "template_file" "user_data_win" {
    template = "${file("user_data.ps1")}"
    vars {
      admin_password  = "${var.admin_password}"
      machine_name    = "${var.machine_name}"
    }
}

resource "aws_instance" "vagabond_win" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.ps-terraform-win.name}"]
    count = "${var.servers}"
    user_data = "${data.template_file.user_data_win.rendered}"
    root_block_device {
        volume_size = "200"
    }
    connection {
      type = "winrm"
      user = "Administrator"
      password = "${var.admin_password}"
      timeout = "10m"
    }
    tags {
        Name = "${var.tagName}-win-${var.patch_id}-${count.index}"
    }
    provisioner "file" {
        source = "${path.module}/../config/psft_customizations-win.yaml"
        destination = "c:/vagrant/config/psft_customizations.yaml"
    }
    provisioner "file" {
        source = "${path.module}/../shared/scripts/vagabond.json"
        destination = "C:/vagrant/scripts/vagabond.json"
    }
    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/banner.ps1"
        destination = "c:/temp/banner.ps1"
    }
    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/provision-download.ps1"
        destination = "c:/temp/provision-download.ps1"
    }    
    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/provision-bootstrap-ps.ps1"
        destination = "c:/temp/provision-bootstrap-ps.ps1"
    }
    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/provision-yaml.ps1"
        destination = "c:/temp/provision-yaml.ps1"
    }
    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/provision-puppet-apply.ps1"
        destination = "c:/temp/provision-puppet-apply.ps1"
    }


    provisioner "remote-exec" {
      connection = {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
        agent       = "false"
      }
      inline = [
        "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
        "powershell.exe -ExecutionPolicy Bypass -File C:\\temp\\banner.ps1"
      ]
    }
    provisioner "remote-exec" {
      connection = {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
        agent       = "false"
      }
      inline = [
        "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
        "powershell.exe -ExecutionPolicy Bypass -Command 'New-Item -ItemType directory -Path c:/psft/dpk/downloads'",
        "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-download.ps1 -MOS_USERNAME ${var.mos_username} -MOS_PASSWORD ${var.mos_password} -PATCH_ID ${var.patch_id} -DPK_INSTALL c:/psft/dpk/download/${var.patch_id}",
      ]
    }
    provisioner "remote-exec" {
      connection = {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
        agent       = "false"
      }
      inline = [
        "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
        "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-bootstrap-ps.ps1 -PATCH_ID ${var.patch_id} -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
      ]
    }
    provisioner "remote-exec" {
      connection = {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
        agent       = "false"
      }
      inline = [
        "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
        "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-yaml.ps1 -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
      ]
    }
    provisioner "remote-exec" {
      connection = {
        type        = "winrm"
        user        = "Administrator"
        password    = "${var.admin_password}"
        agent       = "false"
      }
      inline = [
        "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
        "powershell.exe -ExecutionPolicy Bypass -File c:\\temp\\provision-puppet-apply.ps1 -DPK_INSTALL c:/psft/dpk/download/${var.patch_id} -PSFT_BASE_DIR c:/psft -PUPPET_HOME c:/psft/dpk/puppet",
      ]
    }

}

resource "aws_security_group" "ps-terraform-win" {
    name = "ps-terraform_${var.platform}"
    description = "ps-terraform windows internal traffic + maintenance."

    ingress {
        from_port = 5985
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 1521
        to_port = 1522
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    // This is for outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
