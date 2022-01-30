# Terraform AWS infrastructure management repository

## Abstract

This repository contains Terraform configuration for on-demand AWS infrastructure deployment and Web Services hosting for customer websites.

The infrastructure deployment cycle is fully automated and simplified to standalone configuration.


## Makefile usage
The project is using Makefile for easy plug-in access to popular automation tools and is designed for rapid deployments.

```console

$ make

Usage:
      make <target> <component> <target arguments>

Targets:

    bootstrap        First time setup
    init             Terraform init operations
    plan             Prepare AWS infrastructure Terraform components deployment plan.
    tfplan           Execute Terraform plan (skip init).
    deploy           Deploy AWS infrastructure components.
    create_website   Create AWS site infrastructure and deploy website
    website          Launch Terraform bootstrap and deploy full AWS infrastructure."
    update_website   Clone website git source to S3 for content updates
    tfstate          Check and create AWS s3 Terraform state bucket
    state            Terraform state operations
    output           Show deployed module outputs
    clean            Clean Terraform state and temporary files
    destroy          Remove managed Terraform infrastructure components.
    wipe             Remove managed Terraform infrastructure and clean repository

```

The Terraform project is self-contained and is using minimal dependancies from the operating system.


## OS Dependencies

  * GNU make - https://www.gnu.org/software/make/manual/make.html
  * CURL - https://curl.se/docs/manual.html
  * unzip for unpacking Terraform binary - https://www.hostinger.co.uk/tutorials/how-to-unzip-files-linux/
  * Git - https://git-scm.com/doc
  * AWS CLI for programatic access to AWS management - https://aws.amazon.com/cli/


## AWS Dependencies

  * Administrative IAM account. This also can be service account for already existing automation. The clean separate account is highly recommended.


## Bundled packages

  * Terraform - automatic specified version local directory installation. The documentation is available at https://www.terraform.io/docs


## Project structure

The project is designed in 3 separate components:
  * AWS environment and Terraform environment setup on bootstrap component (https://github.com/arunasp/terraform-website/tree/main/terraform/bootstrap/)
  * AWS network and shared services in site component (https://github.com/arunasp/terraform-website/tree/main/terraform/site/)
  * Website hosting on EC2 instances and shared S3 storage (https://github.com/arunasp/terraform-website/tree/main/terraform/web-service/)


## Terraform components

  * Bootstrap (https://github.com/arunasp/terraform-website/tree/main/terraform/bootstrap/README.md)
  * Site (https://github.com/arunasp/terraform-website/tree/main/terraform/site/README.md)
  * Web-Services (https://github.com/arunasp/terraform-website/tree/main/terraform/web-service/README.md)


## Project usage

For quick Terraform Infrastructure as the code (IaC) demonstration the following options are available:

  * Single make command invocation :
   ```console
   $ make website
   ```
  * Two step installation:
   ```console
   $ make bootstrap
   $ make create_website
   ```
  * Individual components setup:
   ```console
   $ make bootstrap
   $ make plan site
   $ make deploy site
   $ make plan web-service
   $ make deploy web-service
   ```

The successful deployment will result to name of website bucket and AWS Load Balancer hostname for Web browser:

```console
aws_lb_listener.website[0]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-west-2:689316918706:listener/app/website-dev/38fc34dd60ae12aa/c972ce4aa21023f6]
aws_route53_record.lb_alias[0]: Still creating... [10s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [20s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [30s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [40s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [50s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [1m0s elapsed]
aws_route53_record.lb_alias[0]: Still creating... [1m10s elapsed]
aws_route53_record.lb_alias[0]: Creation complete after 1m14s [id=Z03808133IUJEXEFWG4MB_website-dev.internal.local_A]

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

alb_address = [
  "website-dev-1234567890.eu-west-2.elb.amazonaws.com",
]
web_address = "http://website-dev-1234567890.eu-west-2.elb.amazonaws.com/"
website_bucket = [
  "website-dev-eu-west-2-website",
]
~/stuff/aws/terraform-website
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Website deployment complete. Please use address above in few minutes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

If any of components fail to deploy for any reason - after fixing issue it is possible to re-apply it with ```console make plan <componnet> && make deploy <component>``` commands.



## Project configuration parameters

The default installation do not require any external settings except AWS CLI access to account.

The following parameters can be passed via environment variables:

| Envionment variable name | Default value |
| ------------------------ | ------------- |
| TERRAFORM_VERSION | 1.1.4 |
| AWS_PROFILE | default |
| AWS_REGION | eu-west-2 |
| WEBSITE_PROJECT | https://github.com/arunasp/terraform-website-files |
| MODULES_REF | main |
| STACK | website (set to your DevOps project name when needed) |
| STAGE | dev (DevOps - set to your project branch or tag name) |
| TERRAFORM_S3_BUCKET | ${STACK}-${STAGE}-${AWS_REGION}-terraform-state |
| EC2_ADMIN_CIDR | <p>["127.0.0.0/8"]</p> <p>(in (https://github.com/arunasp/terraform-website/tree/main/terraform/variables.tf)</p>Autoset in bootstrap stage to your Internet IP address |
