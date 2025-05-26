output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "DNS name of the existing load balancer"
  value       = data.aws_lb.existing.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "hosted_zone_id" {
  value       = data.aws_route53_zone.existing.zone_id
  description = "ID of the existing hosted zone"
}

output "record_name" {
  value       = data.aws_route53_record.existing.name
  description = "Name of the existing A record"
}

output "target_group_arn" {
  value       = data.aws_lb_target_group.existing.arn
  description = "ARN of the existing target group"
}

output "certificate_arn" {
  value       = data.aws_acm_certificate.existing.arn
  description = "ARN of the existing ACM certificate"
}
