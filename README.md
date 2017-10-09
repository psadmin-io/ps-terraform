# ps-terraform

Run PeopleSoft Images on multiple cloud providers

## Required Software

1. Terraform

## Optional Software (but highly recommended)

1. Git

## Getting Started

There are a few main steps to start using `ps-terraform`:

1. Clone the GitHub repository
1. Configure your cloud provider
1. Set your configuration values
1. Download and initialize Terraform
1. Use Terraform to build the PeopleSoft Image

### Clone the GitHub Repository

1. Clone the Github repo
1. Configure your instance with `psterraform.tfvars`
1. Save `config/psft_customizations.yaml.example` as `config/psft_customizations.yaml`
1. `cd` into the cloud provider folder you want to use (e.g, `cd aws`)
1. Initialize Terraform with `terraform init`
1. Run `terraform plan` to view the infrasturcture to build
1. Run `terraform apply` to build the PeopleSoft Image


