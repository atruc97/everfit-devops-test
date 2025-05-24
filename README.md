# Everfit DevOps Test Project

## Overview

This project demonstrates a CI/CD pipeline for a Node.js application using GitHub Actions, AWS ECS, and ECR. The application is a simple Express server that responds with a welcome message and health status.

## Architecture

- **Application**: Node.js Express server
- **Container**: Docker
- **CI/CD**: GitHub Actions
- **Infrastructure**: AWS (ECS, ECR, ALB)
- **Infrastructure as Code**: Terraform

## Prerequisites

- AWS Account with appropriate permissions
- GitHub Account
- Docker installed locally
- Node.js and npm installed locally
- Terraform installed locally

## Local Development

### Setup

1. Clone the repository:

```bash
git clone https://github.com/atruc97/everfit-devops-test.git
cd everfit-devops-test
```

2. Install dependencies:

```bash
npm install
```

3. Run tests:

```bash
npm test
```

4. Run locally:

```bash
npm start
```

### Docker

Build and run the Docker image locally:

```bash
docker build -t everfit-app .
docker run -p 3000:3000 everfit-app
```

## Infrastructure

### AWS Resources

- ECS Cluster with Fargate
- ECR Repository for Docker images
- Application Load Balancer
- VPC with public and private subnets
- Security Groups
- IAM Roles and Policies

### Terraform

The infrastructure is managed using Terraform. Key resources:

- VPC and networking
- ECS cluster and service
- ECR repository
- ALB and target groups
- Security groups
- IAM roles and policies

To apply the infrastructure:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline is configured in `.github/workflows/ci-cd.yml` and includes:

1. Build and test the application
2. Build Docker image
3. Push to ECR
4. Update ECS service

### Environment Variables

Required GitHub Secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Deployment

The application is automatically deployed when code is pushed to the main branch. The deployment process:

1. Builds a new Docker image
2. Tags it with the commit SHA and 'latest'
3. Pushes to ECR
4. Updates the ECS service

## Testing

The application includes unit tests using Jest:

- Tests the welcome endpoint
- Tests the health check endpoint

Run tests locally:

```bash
npm test
```

## Monitoring

- CloudWatch Logs for application logs
- ECS service metrics
- ALB metrics

## Cleanup

To destroy the infrastructure:

```bash
cd terraform
terraform destroy
```

## License

ISC
