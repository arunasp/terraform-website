# Website hosting

This module creates an instance of Apache hosted on a single EC2 instance.
The Website hosting component is designed for rapid on-demand service deployments and frequent web content updates.

The EC2 instance is managed by an AutoScaling Group and sits behind an Internal Application Load Balancer

The website bucket is mounted on EC2 instances web directory directly. The (https://github.com/s3fs-fuse/s3fs-fuse "S3FS") is used to achieve goal.
Having shared storage across stateless instancess is allowing rapid on-demand AWS infratructure deployment.
The website deployment process can be directly attached to automation pipelines in tools
such as (https://docs.github.com/en/actions "GitHub Actions"), (https://www.jenkins.io/doc/ "Jenkins") and others.
In comparison to AWS S3 web hosting the EC2 instances or Fargate ECS Docker containers are allowing tu run web scripts for dynamic content and use other services backends.

The EC2 instances are running (https://httpd.apache.org/docs/ "Apache web server") installation.



## Managed AWS services

  * AWS Application Load Balancer (ALB)
  * EC2 instances for website hosting
  * EC2 Autoscaling for dynamic instances deployment and scale-in/scale-out
  * Route53 for public ALB DNS hostname
  * IAM roles and policies for EC2 and ALB
  * SSH public key in EC2


## Used AWS services

  * VPC services for EC2 and ALB
  * S3 bucket for website content
  * S3 bucket for Terraform state
  * DynamoDB for Terraform state locking
  * AWS KMS for website S3 bucket encryption
  * AWS KMS for S3 Terraform state bucket encryption
  * IAM roles and policies for services above


## TODO

  * Add other computing deployment options. Such as Fargate ECS Docker service or similar
  * Add RDS management when required for website backends
  * Add instances and ALB health monitoring alerting
  * For the large scale Web Sevices deployments implement other shared storage type attachments
