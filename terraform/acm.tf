# Use existing ACM certificate
data "aws_acm_certificate" "existing" {
  domain      = "sample-app.example.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

