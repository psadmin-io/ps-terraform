# ps-terraform

Run PeopleSoft Images on multiple cloud providers

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

1. Clone the Github repository to your computer
```
git clone https://github.com/psadmin-io/ps-terraform.git
```
1. Save the `psterraform.tfvars.example` to `aws\psterraform.tfvars`
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
1. Save `config/psft_customizations.yaml.example` as `config/psft_customizations.yaml`. Make sure the `db_user` account is appropriate for the Image.

| App | DB User |
| --- | ------- |
| HR  | PS      |
| FS  | VP1     |
| ELM | PS      |
| CS  | PS      |
| HUB | PS      |

### Use Terraform to build a PeopleSoft Image

1. `cd` into the cloud provider folder you want to use (e.g, `cd aws`)
1. Initialize Terraform with `terraform init`
1. Run `terraform plan --varfile=psterraform.tfvars` to view the infrastructure to build
1. Run `terraform apply --varfile=psterraform.tfvars` to build the PeopleSoft Image