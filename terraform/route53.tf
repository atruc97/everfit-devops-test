# Use existing hosted zone
data "aws_route53_zone" "existing" {
  name = "example.com"
}

# Use existing A record
data "aws_route53_record" "existing" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "sample-app.example.com"
  type    = "A"
}

