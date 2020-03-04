# ps-terraform

Run PeopleSoft Images on multiple cloud providers. ps-terraform uses the [ps-vagabond](https://github.com/psadmin-io/ps-vagabond) provisioner scripts to create a RedHat Linux-based PeopleSoft Image automatically.

> **This is not for running production and production support instances. Verify your licensing with Oracle before using this project with a non-demonstration environment as it will impact your license agreement**.

## Required Software

1. Terraform
1. A Cloud Provider Account (e.g, AWS)

## Optional Software (but highly recommended)

1. Git

## Getting Started

There are a few main steps to start using `ps-terraform`:

1. Download Terraform
1. Configure your cloud provider (AWS is the only supported provider at this time)
1. Clone the GitHub repository
1. Use Terraform to build the PeopleSoft Image

### Download Terraform

1. Visit [terraform.io](https://terraform.io) and download Terraform for your platform.
1. Add Terraform to your `$PATH`

```powershell
$env:PATH+=";c:\terraform"
```

```bash
$PATH=$PATH:/opt/terraform
```

### Configure Your Cloud Provider

1. For AWS, create a new account (if you don't have one).
1. Create a new X.509 certificate under "Your Security Credentials > X.509 Certificate"
1. Download the certificate, save it as `terraform.pem` and put it in safe location on your computer.

### Clone the GitHub Repository

Clone the Github repository to your computer

```
git clone https://github.com/psadmin-io/ps-terraform.git
```

Save the `psterraform.tfvars.example` to `aws\psterraform.tfvars`

```ini
mos_username = "dan@company.com"
mos_password = "somethingsecure"
patch_id = "26628883" # HR Image 24

# AWS Variables
key_name = "terraform.pem"
key_path = "/path/to/terraform.pem"

# Optional AWS Variables
region = "" # Default is us-east-1
instance_type = "" # Default is t2.large

# Number of Servers
# Default is 1
# servers = "2"
```

Save `config/psft_customizations.yaml.example` as `config/psft_customizations-win.yaml` or `config/psft_customizations-lnx.yaml`. Make sure the `db_user` account is appropriate for the Image.

| App | DB User |
| --- | ------- |
| HR  | PS      |
| FS  | VP1     |
| ELM | PS      |
| CS  | PS      |
| HUB | VP1     |

### Use Terraform to build a PeopleSoft Image

`cd` into the cloud provider folder you want to use (e.g, `cd aws`)

Initialize Terraform with `terraform init`

```
Initializing provider plugins...

* provider.aws: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Run `terraform plan --var-file=psterraform.tfvars` to view the infrastructure to build

```
$ terraform plan --var-file=psterraform.tfvars
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_security_group.ps-terraform: Refreshing state... (ID: sg-xxxxxxxx)
aws_instance.vagabond[0]: Refreshing state... (ID: i-0b22d8111306a1117)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_instance.vagabond[0]
      id:                                                <computed>
      ami:                                               "ami-c998b6b2"
      associate_public_ip_address:                       <computed>
      availability_zone:                                 <computed>
      ebs_block_device.#:                                "1"
      ebs_block_device.2576023345.delete_on_termination: "true"
      ebs_block_device.2576023345.device_name:           "/dev/sdb"
      ebs_block_device.2576023345.encrypted:             <computed>
      ebs_block_device.2576023345.snapshot_id:           <computed>
      ebs_block_device.2576023345.volume_size:           "4"
      ebs_block_device.2576023345.volume_type:           <computed>
      ephemeral_block_device.#:                          <computed>
      instance_state:                                    <computed>
      instance_type:                                     "t2.large"
      ipv6_address_count:                                <computed>
      ipv6_addresses.#:                                  <computed>
      key_name:                                          "terraform"
      network_interface.#:                               <computed>
      network_interface_id:                              <computed>
      placement_group:                                   <computed>
      primary_network_interface_id:                      <computed>
      private_dns:                                       <computed>
      private_ip:                                        <computed>
      public_dns:                                        <computed>
      public_ip:                                         <computed>
      root_block_device.#:                               "1"
      root_block_device.0.delete_on_termination:         "true"
      root_block_device.0.volume_size:                   "200"
      root_block_device.0.volume_type:                   <computed>
      security_groups.#:                                 "1"
      security_groups.1685318021:                        "ps-terraform_rhel7"
      source_dest_check:                                 "true"
      subnet_id:                                         <computed>
      tags.%:                                            "1"
      tags.Name:                                         "PeopleSoft Image-26427509-0"
      tenancy:                                           <computed>
      user_data:                                         "7cafae4e565a098840a1a56e71735ab43fcc0f16"
      volume_tags.%:                                     <computed>
      vpc_security_group_ids.#:                          <computed>

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Run `terraform apply --var-file=psterraform.tfvars` to build the PeopleSoft Image

```
aws_instance.vagabond: Refreshing state... (ID: i-0b22d8111306a1117)
aws_instance.vagabond: Creating...
  ami:                                               "" => "ami-c998b6b2"
  associate_public_ip_address:                       "" => "<computed>"
  availability_zone:                                 "" => "<computed>"
  ebs_block_device.#:                                "" => "1"
  ebs_block_device.2576023345.delete_on_termination: "" => "true"
  ebs_block_device.2576023345.device_name:           "" => "/dev/sdb"
  ebs_block_device.2576023345.encrypted:             "" => "<computed>"
  ebs_block_device.2576023345.snapshot_id:           "" => "<computed>"
  ebs_block_device.2576023345.volume_size:           "" => "4"
  ebs_block_device.2576023345.volume_type:           "" => "<computed>"
  ephemeral_block_device.#:                          "" => "<computed>"
  instance_state:                                    "" => "<computed>"
  instance_type:                                     "" => "t2.large"
  ipv6_address_count:                                "" => "<computed>"
  ipv6_addresses.#:                                  "" => "<computed>"
  key_name:                                          "" => "terraform"
  network_interface.#:                               "" => "<computed>"
  network_interface_id:                              "" => "<computed>"
  placement_group:                                   "" => "<computed>"
  primary_network_interface_id:                      "" => "<computed>"
  private_dns:                                       "" => "<computed>"
  private_ip:                                        "" => "<computed>"
  public_dns:                                        "" => "<computed>"
  public_ip:                                         "" => "<computed>"
  root_block_device.#:                               "" => "1"
  root_block_device.0.delete_on_termination:         "" => "true"
  root_block_device.0.volume_size:                   "" => "200"
  root_block_device.0.volume_type:                   "" => "<computed>"
  security_groups.#:                                 "" => "1"
  security_groups.1685318021:                        "" => "ps-terraform_rhel7"
  source_dest_check:                                 "" => "true"
  subnet_id:                                         "" => "<computed>"
  tags.%:                                            "" => "1"
  tags.Name:                                         "" => "PeopleSoft Image-26950607-0"
  tenancy:                                           "" => "<computed>"
  user_data:                                         "" => "7cafae4e565a098840a1a56e71735ab43fcc0f16"
  volume_tags.%:                                     "" => "<computed>"
  vpc_security_group_ids.#:                          "" => "<computed>"
aws_instance.vagabond: Provisioning with 'file'...
aws_instance.vagabond: Provisioning with 'file'...
aws_instance.vagabond: Provisioning with 'remote-exec'...
aws_instance.vagabond (remote-exec): Connecting to remote host via SSH...
aws_instance.vagabond (remote-exec): Connected!


aws_instance.vagabond (remote-exec):                                       dP                               dP
aws_instance.vagabond (remote-exec):                                       88                               88
aws_instance.vagabond (remote-exec):   dP   .dP .d8888b. .d8888b. .d8888b. 88d888b. .d8888b. 88d888b. .d888b88
aws_instance.vagabond (remote-exec):   88   d8' 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88
aws_instance.vagabond (remote-exec):   88 .88'  88.  .88 88.  .88 88.  .88 88.  .88 88.  .88 88    88 88.  .88
aws_instance.vagabond (remote-exec):   8888P'   `88888P8 `8888P88 `88888P8 88Y8888' `88888P' dP    dP `88888P8
aws_instance.vagabond (remote-exec):                          .88
aws_instance.vagabond (remote-exec):                      d8888P


aws_instance.vagabond (remote-exec):  ☆  INFO: Updating installed packages
aws_instance.vagabond (remote-exec):  ☆  INFO: Installing additional packages
aws_instance.vagabond (remote-exec):  ☆  INFO: Downloading patch files
aws_instance.vagabond (remote-exec):  ☆  INFO: Unpacking DPK setup scripts
aws_instance.vagabond (remote-exec):  ☆  INFO: Setting file execution attribute on psft-dpk-setup.sh
aws_instance.vagabond (remote-exec):  ☆  INFO: Executing DPK setup script
aws_instance.vagabond (remote-exec):  ☆  INFO: Generating response file
aws_instance.vagabond: Creation complete after 2h26m2s (ID: i-06c2ae56a87c42478)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:
server_address = http://ec2-52-201-216-61.compute-1.amazonaws.com:8000/ps/signon.html
```
