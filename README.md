# Everfit Application

This repository contains a sample application deployed to AWS ECS Fargate using Terraform and GitHub Actions for CI/CD.

## Project Structure

```
.
├── terraform/           # Terraform configuration files
│   ├── main.tf         # Main Terraform configuration
│   ├── variables.tf    # Variable definitions
│   └── outputs.tf      # Output definitions
├── .github/
│   └── workflows/      # GitHub Actions workflows
│       └── ci-cd.yml   # CI/CD pipeline configuration
├── Dockerfile          # Container definition
└── README.md          # This file
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker installed
- Node.js and npm installed

## Infrastructure Setup

1. Navigate to the terraform directory:

   ```bash
   cd terraform
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review the planned changes:

   ```bash
   terraform plan
   ```

4. Apply the infrastructure:
   ```bash
   terraform apply
   ```

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment. The pipeline:

1. Builds the Docker image
2. Pushes it to Amazon ECR
3. Updates the ECS service with the new image

### Required Secrets

Add the following secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Local Development

1. Install dependencies:

   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm start
   ```

## Deployment

The application is automatically deployed when changes are pushed to the main branch. The deployment process:

1. Builds a new Docker image
2. Pushes it to ECR
3. Updates the ECS service

## Infrastructure Components

- VPC with public and private subnets
- ECS Fargate cluster
- Application Load Balancer
- ECR repository
- CloudWatch log groups
- IAM roles and policies

## Cleanup

To destroy the infrastructure:

```bash
cd terraform
terraform destroy
```
