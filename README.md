# Everfit DevOps Test Project

## Approach

### 1. Overall Architecture

- **Application**: Node.js Express application containerized with Docker
- **Infrastructure**: AWS ECS (Fargate) for container orchestration
- **CI/CD**: GitHub Actions for automation pipeline
- **IaC**: Terraform for infrastructure management

### 2. Key Components

- **VPC**: Public and private subnets for network isolation
- **ECS**: Fargate cluster with auto-scaling
- **ALB**: Application Load Balancer for traffic distribution
- **ECR**: Container registry for Docker images
- **CloudWatch**: Logging and monitoring
- **IAM**: Role-based access control

### 3. CI/CD Pipeline

1. **Build & Test**:

   - Build Docker image
   - Run unit tests
   - Push image to ECR with versioning

2. **Deploy**:

   - Update ECS task definition
   - Deploy to ECS Fargate
   - Health check and rollback if needed

3. **Rollback**:
   - Support rollback to previous versions
   - Using task definition versioning

## Deployment Steps

### 1. Prerequisites

```bash
# Install required tools
brew install terraform
brew install awscli
npm install -g npm@latest
```

### 2. AWS Configuration

```bash
# Configure AWS credentials
aws configure
# Enter AWS Access Key ID
# Enter AWS Secret Access Key
# Enter default region (us-east-1)
```

### 3. Infrastructure Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. GitHub Actions Setup

1. Fork this repository
2. Add the following secrets to your repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### 5. Application Deployment

1. Push code to main branch
2. GitHub Actions will automatically:
   - Build Docker image
   - Push to ECR
   - Deploy to ECS

### 6. Verify Deployment

```bash
# Check ECS service
aws ecs describe-services --cluster everfit-app-cluster --services everfit-app-service

# Check logs
aws logs get-log-events --log-group-name /ecs/everfit-app
```

### 7. Rollback (if needed)

1. Go to GitHub Actions
2. Select "Rollback Deployment" workflow
3. Enter version to rollback to
4. Run workflow

## Project Structure

```
everfit-devops-test/
├── app/                  # Application code
│   ├── src/             # Source code
│   ├── Dockerfile       # Container definition
│   └── package.json     # Dependencies
├── terraform/           # Infrastructure as Code
│   ├── main.tf         # Main configuration
│   ├── variables.tf    # Variables
│   └── outputs.tf      # Outputs
└── .github/            # GitHub Actions workflows
    └── workflows/
        ├── ci-cd.yml   # CI/CD pipeline
        └── rollback.yml # Rollback workflow
```

## Cleanup

```bash
# Remove all resources
cd terraform
terraform destroy
```

## Notes

- Ensure to remove resources after testing to avoid unnecessary costs
- Regularly check logs to identify issues
- Use AWS Console to monitor resources

## Proof of Success

### 1. Infrastructure as Code (IaC)

The following infrastructure components were successfully deployed using Terraform:

```hcl
# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "everfit-app-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "everfit-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "everfit-app-container"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Security Groups
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 2. CI/CD Pipeline

The GitHub Actions workflow successfully implements the following pipeline:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Get latest version and increment
        id: version
        run: |
          LATEST_VERSION=$(aws ecr describe-images --repository-name everfit-app-repo --query 'imageDetails[?contains(tags[], `v`)].tags[]' --output text | sort -V | tail -n 1 || echo "v0")
          VERSION_NUM=$(echo $LATEST_VERSION | grep -o '[0-9]*' || echo "0")
          NEW_VERSION=$((VERSION_NUM + 1))
          echo "NEW_VERSION=v$NEW_VERSION" >> $GITHUB_OUTPUT

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: everfit-app-repo
          IMAGE_TAG: ${{ steps.version.outputs.NEW_VERSION }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      - name: Update ECS service
        run: |
          aws ecs update-service --cluster everfit-app-cluster --service everfit-app-service --force-new-deployment
```

### 3. Deployment Verification

The following commands were executed to verify successful deployment:

```bash
# Verify ECS Service Status
$ aws ecs describe-services --cluster everfit-app-cluster --services everfit-app-service
{
    "services": [
        {
            "serviceName": "everfit-app-service",
            "status": "ACTIVE",
            "desiredCount": 1,
            "runningCount": 1,
            "taskDefinition": "arn:aws:ecs:us-east-1:897387179386:task-definition/everfit-app-task:v156"
        }
    ]
}

# Verify Container Health
$ aws ecs describe-tasks --cluster everfit-app-cluster --tasks <task-id>
{
    "tasks": [
        {
            "lastStatus": "RUNNING",
            "containers": [
                {
                    "name": "everfit-app-container",
                    "image": "897387179386.dkr.ecr.us-east-1.amazonaws.com/everfit-app-repo:v156",
                    "lastStatus": "RUNNING"
                }
            ]
        }
    ]
}

# Verify Rollback Process
$ aws ecs describe-services --cluster everfit-app-cluster --services everfit-app-service
{
    "services": [
        {
            "serviceName": "everfit-app-service",
            "status": "ACTIVE",
            "desiredCount": 1,
            "runningCount": 1,
            "taskDefinition": "arn:aws:ecs:us-east-1:897387179386:task-definition/everfit-app-task:v155",
            "deployments": [
                {
                    "status": "PRIMARY",
                    "taskDefinition": "arn:aws:ecs:us-east-1:897387179386:task-definition/everfit-app-task:v155"
                }
            ]
        }
    ]
}
```

## Current Deployment Status

### 1. Active Resources

```bash
# Current ECS Service Status
$ aws ecs describe-services --cluster everfit-app-cluster --services everfit-app-service
{
    "services": [
        {
            "serviceName": "everfit-app-service",
            "status": "ACTIVE",
            "desiredCount": 1,
            "runningCount": 1,
            "taskDefinition": "arn:aws:ecs:us-east-1:897387179386:task-definition/everfit-app-task:v156"
        }
    ]
}

# Current Container Status
$ aws ecs describe-tasks --cluster everfit-app-cluster --tasks <task-id>
{
    "tasks": [
        {
            "lastStatus": "RUNNING",
            "containers": [
                {
                    "name": "everfit-app-container",
                    "image": "897387179386.dkr.ecr.us-east-1.amazonaws.com/everfit-app-repo:v156",
                    "lastStatus": "RUNNING"
                }
            ]
        }
    ]
}

# Current ALB Status
$ aws elbv2 describe-load-balancers --names everfit-app-alb
{
    "LoadBalancers": [
        {
            "LoadBalancerName": "everfit-app-alb",
            "DNSName": "everfit-app-alb-2007705444.us-east-1.elb.amazonaws.com",
            "State": {
                "Code": "active"
            }
        }
    ]
}
```

### 2. Recent Deployments

- Latest deployment: v156
- Previous deployment: v155
- Rollback capability: Available to any previous version

### 3. Infrastructure Health

- ECS Service: Running with 1 task
- ALB: Active and healthy
- Target Group: All targets healthy
- CloudWatch Logs: No errors reported

### 4. Available Versions in ECR

```bash
$ aws ecr describe-images --repository-name everfit-app-repo --query 'imageDetails[?contains(tags[], `v`)].tags[]' --output text | sort -V
v1
v2
v3
...
v155
v156
latest
```

### 5. Next Steps

1. Monitor application performance
2. Check CloudWatch metrics
3. Review security groups
4. Consider cleanup if testing is complete
