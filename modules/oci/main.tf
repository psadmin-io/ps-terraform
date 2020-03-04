
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

data {
  oci_identity_availability_domains {
    primary_availability_domains {
      compartment_id = "${var.tenancy_ocid}"
    }
  }
}

resource {
  # OCI Compartment
  oci_identity_compartment {
    compartment {
      compartment_id = "${var.tenancy_ocid}"
      description = "${var.compartment_description}"
      name = "${var.oci_name}"
    }
  }

  oci_identity_policy { 
    policy {
      compartment_id = "${var.tenancy_ocid}"
      description = "${var.policy_description}"
      name = "${var.oci_name}"
      statements = "${var.policy_statements}"
    }
  }

  # Networking
  oci_core_vcn { 
    vcn {
      cidr_block = "${var.vcn_cidr_block}"
      display_name = "Vagabond-Network"
      compartment_id = "${oci_identity_compartment.compartment.id}"
    } 
  }

  oci_core_internet_gateway { 
    internet_gateway {
      compartment_id = "${oci_identity_compartment.compartment.id}"
      vcn_id = "${oci_core_vcn.vcn.id}"
    }
  }

  oci_core_route_table {
    route_table {
      compartment_id = "${oci_identity_compartment.compartment.id}"
      vcn_id         = "${oci_core_vcn.vcn.id}"
      
      route_rules {
        cidr_block        = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.internet_gateway.id}"
      }
    }
  }

  oci_core_security_list {
    security_list {
      compartment_id = "${oci_identity_compartment.compartment.id}"
      egress_security_rules = [
        {
          protocol    = "6"
          destination = "0.0.0.0/0"
        }
      ]
      ingress_security_rules = [
        {
          protocol = "6"
          source   = "0.0.0.0/0"

          tcp_options = {
            min = "22"
            max = "22"
          }
        },{
          protocol = "6"
          source   = "0.0.0.0/0"

          tcp_options = {
            min = "8443"
            max = "8443"
          }
        },{
          protocol = "6"
          source   = "0.0.0.0/0"

          tcp_options = {
            min = "8000"
            max = "8000"
          }
        },{
          protocol = "6"
          source   = "0.0.0.0/0"

          tcp_options = {
            min = "3389"
            max = "3389"
          }
        },{
          protocol = "6"
          source   = "10.0.1.0/24"
        },{
          protocol = "6"
          source   = "10.0.0.0/24"

          tcp_options = {
            min = "5985"
            max = "5986"
          }
        },{
          protocol = "6"
          source   = "10.0.1.0/24"

          tcp_options = {
            min = "9200"
            max = "9200"
          }
        },{
          protocol = "6"
          source   = "10.0.0.0/24"

          tcp_options = {
            min = "1521"
            max = "1522"
          }
        }
      ]
      vcn_id = "${oci_core_vcn.vcn.id}"
    }
  }

  /*oci_core_subnet {
    public-subnet {
      count               = 3
      availability_domain = "${lookup(data.oci_identity_availability_domains.primary_availability_domains.availability_domains[count.index],"name")}"
      cidr_block          = "10.0.${count.index}.0/24"
      display_name        = "${oci_core_virtual_network.main.display_name}-subnet${count.index}pub"
      dns_label           = "subnet${count.index}pub"
      security_list_ids   = ["${oci_core_security_list.public-sl.id}"]
      compartment_id      = "${var.compartment}"
      vcn_id              = "${oci_core_virtual_network.main.id}"
      route_table_id      = "${oci_core_route_table.public-rt.id}"
      dhcp_options_id     = "${oci_core_dhcp_options.DhcpOptions.id}"
    }
  }*/

  # Instance
  oci_core_instance {
    vagabond_lnx {
      availability_domain = "${data.oci_identity_availability_domains.primary_availability_domains[0].id}"
      compartment_id = "${var.compartment_id}"
      shape = "${var.instance_shape}"

      // #Optional
      // create_vnic_details {
      //     #Required
      //     subnet_id = "${oci_core_subnet.test_subnet.id}"

      //     #Optional
      //     assign_public_ip = "true"
      //     display_name = "Public VNIC"
      //     private_ip = "10.0.0.10"
      // }
      display_name = "${var.image_name}"
      hostname_label = "${var.hostname}"
      // ipxe_script = "${var.instance_ipxe_script}"
      metadata {
          ssh_authorized_keys = "${var.ssh_public_key}"
          // user_data = "${base64encode(file(var.custom_bootstrap_file_name))}"
      }
      image = "${var.base_image}"
      preserve_boot_volume = false
      }
  }
}