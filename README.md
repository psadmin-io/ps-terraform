# ps-terraform

Run PeopleSoft Images on multiple cloud providers

## Getting Started

1. Clone the Github repo
1. Configure `terraform.tfvars`
1. Save `config/psft_customizations.yaml.example` as `config/psft_customizations.yaml`
1. `cd` into the cloud provider folder you want to use (e.g, `cd aws`)
1. Initialize Terraform with `terraform init`
1. Run `terraform plan` to view the infrasturcture to build
1. Run `terraform apply` to build the PeopleSoft Image


