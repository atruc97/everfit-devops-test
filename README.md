# Everfit DevOps Test

## Overview

This project deploys a simple Node.js application on AWS ECS using Fargate, with automated CI/CD pipeline through GitHub Actions. Infrastructure is managed using Terraform.

## Project Structure

```
project-root/
├── app/
│   ├── src/
│   ├── index.js
│   ├── package.json
│   ├── package-lock.json
│   ├── Dockerfile
│   └── .dockerignore
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── route53.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── .github/
│   └── workflows/
│       ├── ci-deployment.yml
│       └── ci-rollback-images.yml
├── .gitignore
└── README.md
```

## Solution Architecture

### 1. Infrastructure as Code (Terraform)

- **VPC and Networking**:

  - VPC with CIDR 10.0.0.0/16
  - 2 Public Subnets and 2 Private Subnets
  - NAT Gateway for private subnets
  - Internet Gateway for public subnets

- **ECS Configuration**:

  - ECS Cluster: everfit-app-cluster
  - ECS Service: everfit-app-service
  - Task Definition with Fargate
  - Auto Scaling with CPU and Memory metrics

- **Load Balancer**:

  - Application Load Balancer (ALB)
  - Target Group with health check
  - Security Group for ALB

- **ECR Repository**:

  - Repository: everfit-app-repo
  - Lifecycle policy for image management

- **IAM Roles and Policies**:
  - Task Execution Role
  - Task Role
  - Service Role for ECS

### 2. CI/CD Pipeline (GitHub Actions)

#### Main Workflow (ci-deployment.yml):

```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    steps:
      - Setup Node.js
      - Install Dependencies
      - Run Tests
      - Configure AWS credentials
      - Login to ECR
      - Build and Push Docker image
      - Update ECS service
```

#### Rollback Workflow (ci-rollback-images.yml):

```yaml
name: Rollback Deployment
on:
  workflow_dispatch:
    inputs:
      version:
        description: "Version to rollback to (e.g., v1, v2, v3)"
        required: true
        type: string

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Rollback to specific version
        run: |
          aws ecs update-service \
            --cluster everfit-app-cluster \
            --service everfit-app-service \
            --task-definition everfit-app-task \
            --force-new-deployment \
            --query 'service.taskDefinition' \
            --output text
```

#### Version Management:

- Automatic version increment (v1, v2, v3...)
- Tag images with both latest and specific versions
- Rollback workflow to revert to previous versions

### 3. Security Groups

```hcl
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "everfit-app-alb-sg"
  description = "ALB Security Group"
  vpc_id      = "vpc-04390ce84a4cb4014"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "everfit-app"
    Environment = "production"
  }
}

# ECS Task Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "everfit-app-ecs-tasks-sg"
  description = "ECS Tasks Security Group"
  vpc_id      = "vpc-04390ce84a4cb4014"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "everfit-app"
    Environment = "production"
  }
}
```

### 4. Task Definition

```json
{
  "family": "everfit-app-task",
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:897387179386:task-definition/everfit-app-task:5",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "taskRoleArn": "arn:aws:iam::897387179386:role/everfit-app-ecs-task-role",
  "executionRoleArn": "arn:aws:iam::897387179386:role/everfit-app-ecs-execution-role",
  "containerDefinitions": [
    {
      "name": "everfit-app-container",
      "image": "897387179386.dkr.ecr.us-east-1.amazonaws.com/everfit-app-repo:v2",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/everfit-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

## Deployment Steps

### 1. Installation and Setup

1. Clone repository
2. Install required tools:
   - AWS CLI
   - Terraform
   - Docker
   - Node.js

### 2. AWS Configuration

1. Create IAM user with necessary permissions
2. Configure AWS credentials
3. Set up GitHub secrets:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY

### 3. Infrastructure Deployment

1. Initialize Terraform:

   ```bash
   cd terraform
   terraform init
   ```

2. Review deployment plan:

   ```bash
   terraform plan
   ```

3. Deploy infrastructure:
   ```bash
   terraform apply
   ```

### 4. Application Deployment

1. Push code to GitHub repository
2. CI/CD pipeline will automatically:
   - Build and test application
   - Build Docker image
   - Push image to ECR
   - Deploy to ECS

### 5. Verification and Monitoring

1. Check ECS service status
2. Monitor CloudWatch logs
3. Verify ALB health checks

### 6. Rollback (if needed)

1. Go to GitHub Actions
2. Select "Rollback Deployment" workflow
3. Enter version to rollback to (e.g., v1, v2, v3)
4. Run workflow
5. The workflow will:
   - Configure AWS credentials
   - Login to ECR
   - Update ECS service to use the specified version
   - Force a new deployment

## Monitoring and Logging

- CloudWatch Logs for container logs
- CloudWatch Metrics for ECS service
- ALB health check monitoring
- ECS service events

## Outputs

After deployment, Terraform will output:

- ECS cluster name
- ECS service name
- ALB DNS name
- ECR repository URL
- Task definition ARN
- VPC ID

## Domain Configuration

The application is configured to be accessible via the domain `sample-app.example.com`. This is set up using AWS Route53:

1. A hosted zone is created for `example.com`
2. An A record is created for `sample-app.example.com` that points to the Application Load Balancer
3. The ALB handles the routing of traffic to the ECS service

### Route53 Configuration

The Route53 configuration is managed through Terraform in `terraform/route53.tf`:

```hcl
resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "sample-app.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
```

### DNS Configuration Steps

1. Ensure your domain's nameservers are updated to point to AWS nameservers
2. Apply the Terraform configuration to create the Route53 resources
3. Wait for DNS propagation (can take up to 48 hours)
4. Access your application at `https://sample-app.example.com`
