provider "aws" {
  region     = "${var.region}"
}

data "template_file" "init" {
    template = <<EOF
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  $admin = [ADSI]("WinNT://./administrator, user")
  $admin.SetPassword("${var.admin_password}")
EOF

  vars {
    admin_password = "${var.admin_password}"
  }
}

resource "aws_instance" "vagabond-win" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.ps-terraform.name}"]
    count = "${var.servers}"

    root_block_device {
        volume_size = "200"
    }

    # ebs_block_device {
    #     device_name = "/dev/sdb"
    #     volume_size = "4"
    # }

    # connection {
    #     user = "${lookup(var.user, var.platform)}"
    #     private_key = "${file("${var.key_path}")}"
    # }
    connection {
      type = "winrm"
      user = "Administrator"
      password = "${var.admin_password}"
    }

    user_data = "${data.template_file.init.rendered}"

    #Instance tags
    tags {
        Name = "${var.tagName}-${var.patch_id}-${count.index}"
    }

    provisioner "file" {
        source = "${path.module}/../config/psft_customizations.yaml"
        destination = "c:/vagrant/config/psft_customizations.yaml"
    }

    provisioner "file" {
        source = "${path.module}/../shared/scripts/vagabond.json"
        destination = "C:/vagrant/scripts/vagabond.json"
    }

    # provisioner "remote-exec" {
    #     scripts = [
    #         "${path.module}/../shared/scripts/ip_tables.sh"
    #     ]
    # }

    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/banner.ps1"
        destination = "c:/temp/banner.ps1"
    }

    provisioner "remote-exec" {
      inline = [
        "c:/temp/banner.ps1",
      ]
    }

    provisioner "file" {
        source = "${path.module}/../shared/scripts/win/provision-download.ps1"
        destination = "c:/temp/provision-download.ps1"
    }

    provisioner "remote-exec" {
      inline = [
        "c:/temp/provision-download.ps1 -MOS_USERNAME ${var.mos_username} -MOS_PASSWORD ${var.mos_password} -PATCH_ID ${var.patch_id} -DPK_INSTALL c:/psft/dpk/download/${var.patch_id}",
      ]
    }
}

resource "aws_security_group" "ps-terraform" {
    name = "ps-terraform_${var.platform}"
    description = "ps-terraform internal traffic + maintenance."

    // These are for internal traffic
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    // These are for maintenance
    ingress {
        from_port = 5985
        to_port = 5985
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
        from_port = 1522
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