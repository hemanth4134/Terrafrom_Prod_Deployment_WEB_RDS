Production AWS Web Service Infrastructure with Terraform

This project provisions a production-oriented AWS web application infrastructure using Terraform and follows the key principles of the AWS Well-Architected Framework.

The infrastructure provides:

Highly available web application
AWS Application Load Balancer
ECS Fargate containers
Amazon RDS PostgreSQL
Private S3 bucket
Multi-AZ VPC networking
Private subnets for application and database workloads
IAM least-privilege access
CloudWatch logging
ECS autoscaling
RDS automated backups
Encryption at rest
Security groups following least-privilege principles
HTTPS termination through the Application Load Balancer
Architecture
                           Internet
                              |
                              v
                         Route 53
                              |
                              v
                         CloudFront
                              |
                              v
                            WAF
                              |
                              v
                    Application Load Balancer
                       /                  \
                      /                    \
             Public Subnet AZ-A      Public Subnet AZ-B
                    |                       |
                    +----------+------------+
                               |
                               v
                     Private Application Subnets
                       /                    \
                      /                      \
              ECS Fargate AZ-A        ECS Fargate AZ-B
                    |                       |
                    +-----------+-----------+
                                |
                                v
                         RDS PostgreSQL
                            Multi-AZ
                               
                  ECS Task IAM Role
                         |
              +----------+----------+
              |                     |
              v                     v
             S3                 CloudWatch
          Application             Logs
            Bucket

Note: Route 53, CloudFront, WAF and the HTTPS certificate are recommended production additions. The core Terraform implementation provisions the VPC, ALB, ECS, RDS, S3 and CloudWatch components.

AWS Well-Architected Considerations

The architecture considers the six pillars of the AWS Well-Architected Framework.

1. Operational Excellence

The infrastructure is managed as code using Terraform.

Benefits:

Repeatable deployments
Version-controlled infrastructure
Automated changes
Easier disaster recovery
Infrastructure review through Git pull requests

Recommended CI/CD checks:

terraform fmt
terraform validate
terraform plan
Checkov
tfsec
2. Security

Security controls include:

RDS is not publicly accessible
ECS tasks run in private subnets
ALB is the internet-facing component
RDS only accepts PostgreSQL traffic from ECS
ECS receives traffic only from the ALB
S3 public access is blocked
S3 versioning is enabled
IAM follows least-privilege principles
S3 access is restricted to the application bucket
Encryption is enabled for RDS and S3

Traffic flow:

Internet
   |
   v
ALB
   |
   v
ECS
   |
   +-------> RDS
   |
   +-------> S3

The database is never directly exposed to the internet.

3. Reliability

The infrastructure uses multiple Availability Zones.

                VPC
                 |
        +--------+--------+
        |                 |
       AZ-A              AZ-B
        |                 |
       ALB               ALB
        |                 |
       ECS               ECS
        \                 /
         \               /
          RDS Multi-AZ

Reliability features include:

Multiple Availability Zones
Multiple ECS tasks
ECS health checks
ALB health checks
RDS Multi-AZ
RDS automated backups
ECS deployment circuit breaker
ECS autoscaling
RDS deletion protection
S3 versioning
4. Performance Efficiency

ECS Fargate provides scalable compute without managing EC2 servers.

ECS autoscaling is configured based on CPU utilization.

CPU < target
     |
     v
Maintain capacity

CPU > target
     |
     v
Scale ECS tasks

Example:

Minimum ECS tasks: 2
Maximum ECS tasks: 10
CPU target:        60%

The CPU and memory allocation can be adjusted using Terraform variables.

5. Cost Optimization

The infrastructure is designed to balance availability and cost.

Cost considerations include:

ECS Fargate instead of permanently running EC2 instances
ECS autoscaling
RDS storage autoscaling
S3 lifecycle management
CloudWatch log retention
Configurable ECS CPU/memory
Configurable RDS instance type

For development environments, consider:

ECS desired count = 1
RDS smaller instance
Single NAT Gateway
Shorter CloudWatch retention

For production:

ECS desired count >= 2
RDS Multi-AZ
NAT Gateway per AZ
Longer log retention
Automated backups
6. Sustainability

The architecture avoids unnecessary infrastructure capacity by using:

ECS autoscaling
Right-sized Fargate tasks
RDS storage autoscaling
S3 lifecycle policies
Log retention policies

Resources should be continuously reviewed and right-sized based on actual utilization.

Project Structure
terraform-web-service/
│
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
│
├── networking.tf
├── security.tf
├── iam.tf
├── s3.tf
├── rds.tf
├── ecs.tf
├── alb.tf
├── autoscaling.tf
├── cloudwatch.tf
│
├── outputs.tf
├── terraform.tfvars
└── README.md
Components
VPC

The VPC contains:

10.0.0.0/16

Subnets:

Public:
10.0.1.0/24
10.0.2.0/24

Private:
10.0.11.0/24
10.0.12.0/24

Database:
10.0.21.0/24
10.0.22.0/24

Public subnets contain the Application Load Balancer.

Private subnets contain ECS Fargate tasks.

Database subnets contain RDS.

ECS Fargate

The application runs on Amazon ECS Fargate.

Example configuration:

CPU:       512
Memory:    1024 MB
Port:      8080
Tasks:     2
Maximum:   10

The application container must expose the configured application port.

Example:

8080
Application Health Check

The application should expose:

GET /health

The endpoint should return HTTP:

200 OK

Example response:

{
  "status": "healthy"
}

The ALB and ECS use this endpoint to determine application health.

RDS PostgreSQL

The database uses Amazon RDS PostgreSQL.

Configuration includes:

PostgreSQL
Multi-AZ
Private database subnets
Encryption at rest
Automated backups
Storage autoscaling
Performance Insights
CloudWatch log exports
Deletion protection

Database access is restricted using security groups.

ECS Security Group
        |
        | TCP 5432
        v
RDS Security Group

No internet access to PostgreSQL is allowed.

S3

The application receives access to a private S3 bucket.

Security controls:

Block Public Access = Enabled
Versioning          = Enabled
Encryption          = Enabled
Lifecycle            = Enabled

The ECS task receives only the required permissions:

s3:GetObject
s3:PutObject
s3:DeleteObject
s3:ListBucket

The application should not receive:

AmazonS3FullAccess

This follows the principle of least privilege.

IAM

Two ECS IAM roles are used.

ECS Execution Role

Used by ECS/Fargate for operations such as:

Pulling container images
Writing logs to CloudWatch
Retrieving required runtime resources
ECS Task Role

Used by the application itself.

The task role provides restricted access to the application S3 bucket.

This separation prevents the application from receiving unnecessary AWS permissions.

Security Groups

Three primary security groups are created.

ALB Security Group

Allows:

TCP 80
TCP 443

from the internet.

ECS Security Group

Allows application traffic only from the ALB.

ALB SG
  |
  | TCP 8080
  v
ECS SG
RDS Security Group

Allows:

ECS SG
   |
   | TCP 5432
   v
RDS SG

No public CIDR is allowed to access PostgreSQL.

Prerequisites

Before deploying, install:

Terraform
AWS CLI
Git
Docker
An AWS account
Appropriate AWS IAM permissions

Verify Terraform:

terraform version

Verify AWS CLI:

aws --version

Verify AWS credentials:

aws sts get-caller-identity
AWS Authentication

Configure AWS credentials using the AWS CLI:

aws configure

Alternatively, use an AWS profile:

export AWS_PROFILE=production

For CI/CD, use an IAM role or OIDC-based authentication instead of long-lived access keys.

Container Image

The ECS service expects a Docker image.

Example ECR image:

123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-web-service:1.0.0

Build the application:

docker build -t my-web-service:1.0.0 .

Authenticate with ECR:

aws ecr get-login-password \
  --region eu-west-2 | \
  docker login \
  --username AWS \
  --password-stdin \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com

Tag the image:

docker tag \
  my-web-service:1.0.0 \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-web-service:1.0.0

Push the image:

docker push \
  123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-web-service:1.0.0
Configuration

Create:

terraform.tfvars

Example:

aws_region   = "eu-west-2"
project_name = "my-web-service"
environment  = "prod"

container_image = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-web-service:1.0.0"

container_port = 8080

desired_count = 2

cpu    = 512
memory = 1024

db_name     = "application"
db_username = "appadmin"

db_instance_class = "db.t4g.medium"

acm_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Important

Do not commit database passwords to Git.

Do not put secrets directly into:

terraform.tfvars

Instead:

export TF_VAR_db_password="your-password"

For enterprise production environments, use AWS Secrets Manager.

Terraform Deployment
1. Initialize Terraform
terraform init
2. Format Terraform
terraform fmt -recursive
3. Validate configuration
terraform validate

Expected result:

Success! The configuration is valid.
4. Review deployment plan
terraform plan

Review all resources before deployment.

5. Deploy
terraform apply

Confirm:

yes
Retrieve Outputs

After deployment:

terraform output

Example:

alb_dns_name
s3_bucket_name
rds_endpoint
ecs_cluster_name
vpc_id

Application URL:

https://<ALB-DNS-NAME>
Testing
Test the health endpoint
curl https://<ALB-DNS-NAME>/health

Expected:

{
  "status": "healthy"
}
View ECS Logs

Find the ECS CloudWatch log group:

/ecs/my-web-service-prod

Using AWS CLI:

aws logs tail \
  /ecs/my-web-service-prod \
  --follow
Verify ECS Service
aws ecs describe-services \
  --cluster my-web-service-prod \
  --services my-web-service-prod
Verify RDS
aws rds describe-db-instances \
  --db-instance-identifier my-web-service-prod-postgres

The database should show:

PubliclyAccessible: false
Verify S3 Security

Check public access block:

aws s3api get-public-access-block \
  --bucket <bucket-name>

The bucket should have all public access blocking options enabled.

Terraform State

For production, Terraform state should not be stored locally.

Recommended architecture:

Terraform
    |
    v
S3 Backend
    |
    +--> Versioning
    |
    +--> Encryption
    |
    +--> Restricted IAM access

Use a dedicated AWS account or tightly restricted bucket for Terraform state.

Example backend configuration:

terraform {
  backend "s3" {
    bucket       = "company-production-terraform-state"
    key          = "web-service/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

The backend bucket should be created and secured separately from the application infrastructure.

Recommended CI/CD Pipeline

A production pipeline should look like:

Developer
    |
    v
Git Push
    |
    v
CI Pipeline
    |
    +--> terraform fmt
    |
    +--> terraform validate
    |
    +--> Security Scan
    |       |
    |       +--> Checkov
    |       +--> tfsec
    |
    +--> terraform plan
    |
    v
Manual Approval
    |
    v
terraform apply
    |
    v
AWS

For application deployment:

Git
 |
 v
Build
 |
 v
Unit Tests
 |
 v
Docker Build
 |
 v
Security Scan
 |
 v
Push to ECR
 |
 v
ECS Deployment
 |
 v
ALB Health Check
 |
 v
Production
Production Security Checklist

Before production deployment:

Enable AWS CloudTrail

Enable AWS GuardDuty

Enable AWS Security Hub

Enable AWS Config

Configure AWS WAF

Configure ACM TLS certificate

Configure Route 53

Use HTTPS only

Disable unnecessary HTTP access

Store secrets in Secrets Manager

Enable RDS encryption

Enable S3 encryption

Block S3 public access

Enable S3 versioning

Enable RDS deletion protection

Configure RDS backups

Restrict IAM permissions

Use separate AWS accounts/environments

Enable CloudTrail logging

Configure CloudWatch alarms

Configure budget alerts

Scan container images

Scan Terraform code

Protect Terraform state

Enable Git branch protection

Recommended Monitoring

Create CloudWatch alarms for:

ECS
CPUUtilization
MemoryUtilization
RunningTaskCount
DesiredTaskCount
ALB
HTTPCode_Target_5XX_Count
TargetResponseTime
HealthyHostCount
UnHealthyHostCount
RDS
CPUUtilization
FreeStorageSpace
DatabaseConnections
FreeableMemory
ReadLatency
WriteLatency
Disaster Recovery

Recommended production strategy:

Primary Region
      |
      +---- RDS automated backups
      |
      +---- RDS snapshots
      |
      +---- S3 versioning
      |
      v
Secondary Region

For business-critical applications, consider:

Cross-region RDS backups
S3 cross-region replication
Infrastructure deployment into a secondary region
Route 53 failover
Documented recovery procedures
Regular disaster recovery testing
Backup Strategy

Recommended baseline:

RDS
 |
 +--> Automated backups
 |
 +--> Multi-AZ
 |
 +--> Manual snapshots
 |
 +--> Cross-region backup

S3:

S3
 |
 +--> Versioning
 |
 +--> Lifecycle rules
 |
 +--> Cross-region replication
Environment Strategy

Do not use the same infrastructure for every environment.

Recommended:

AWS Account / Environment

├── Development
├── Staging
└── Production

Example:

terraform/
├── modules/
│   ├── networking/
│   ├── ecs/
│   ├── rds/
│   └── s3/
│
└── environments/
    ├── dev/
    ├── stage/
    └── prod/

Production should ideally have a separate AWS account.

Terraform Best Practices

Follow these practices:

Pin provider versions.
Pin module versions.
Use remote Terraform state.
Never commit secrets.
Use variables instead of hard-coded values.
Use reusable modules.
Run terraform fmt.
Run terraform validate.
Review terraform plan.
Run security scanners.
Use CI/CD for production deployments.
Require pull-request approval.
Enable state versioning.
Use separate environments.
Avoid manual changes in AWS Console.
Destroying the Infrastructure

To destroy the infrastructure:

terraform destroy

Warning: This will delete infrastructure managed by this Terraform configuration. RDS has deletion protection enabled, so production database deletion requires an intentional additional step.

Never run this command against production without reviewing the plan and organizational approval.

Troubleshooting
ECS tasks are not starting

Check:

aws ecs describe-services \
  --cluster <cluster-name> \
  --services <service-name>

Then inspect CloudWatch logs:

aws logs tail /ecs/<service-name> --follow

Common causes:

Invalid container image
ECR permission issue
Incorrect container port
Application startup failure
Insufficient CPU/memory
Security group issue
Missing environment variables
ALB returns 503

Check:

ALB
 |
 +--> Target Group
       |
       +--> ECS Tasks

Common causes:

ECS task isn't healthy
/health endpoint doesn't return 200
Incorrect container port
Security group blocks ALB → ECS traffic
Application isn't listening on 0.0.0.0
Container startup failure
ECS cannot access S3

Check the ECS task role.

Verify:

s3:GetObject
s3:PutObject
s3:DeleteObject
s3:ListBucket

Also verify that the resource ARN points to the correct bucket.

ECS cannot connect to RDS

Check:

ECS Security Group
        |
        | TCP 5432
        v
RDS Security Group

Verify:

RDS is in private subnets
ECS is in private subnets
RDS SG allows TCP 5432 from ECS SG
Correct database endpoint is configured
Correct credentials are configured
PostgreSQL is listening on port 5432
Cost Considerations

This architecture uses several AWS services that generate ongoing costs.

Major cost components include:

ECS Fargate
RDS
NAT Gateway
Application Load Balancer
CloudWatch
S3
Data Transfer

For non-production environments, costs can be reduced by:

Smaller RDS instance
Single NAT Gateway
Lower ECS desired count
Lower log retention
Smaller storage

Do not automatically apply these cost reductions to production without evaluating availability requirements.

Future Enhancements

The following enhancements can be added:

CloudFront

AWS WAF

Route 53

ACM

AWS Secrets Manager

KMS customer-managed keys

ECR repository

ECR image scanning

Blue/green ECS deployment

CodePipeline

CodeBuild

GitHub Actions

CloudWatch alarms

SNS notifications

AWS Backup

Cross-region disaster recovery

Terraform modules

Separate AWS accounts

Policy-as-code

Checkov

tfsec

Infracost

License

This project is provided as an infrastructure reference implementation.

Before using it in production, review the configuration against your organization's:

Security policies
Compliance requirements
Availability requirements
Disaster recovery requirements
Cost requirements
AWS account structure
Data protection policies
Summary

This Terraform project provides a production-oriented AWS web service architecture:

                  Internet
                     |
                     v
                    ALB
                     |
              +------+------+
              |             |
             ECS           ECS
              |             |
              +------+------+
                     |
                     v
                RDS Multi-AZ

                 ECS Task
                    |
             +------+------+
             |             |
             v             v
            S3         CloudWatch

The design prioritizes:

Security + Reliability + Performance + Cost Optimization + Operational Excellence + Sustainability

It provides a strong foundation for deploying a real-world web application on AWS while maintaining infrastructure as code through Terraform.                        
        
