locals {
  s3_bucket_name = "cloud-programming-exam"
}

resource "aws_s3_bucket" "main" {
  bucket = local.s3_bucket_name
}

resource "aws_s3_object" "object" {
  depends_on = [ aws_s3_bucket.main ]
  bucket = aws_s3_bucket.main.id
  key    = "index.html"
  source = "website_content/index.html"

  content_type = "text/html"
}


// Creates an AWS CloudFront web distribution
resource "aws_cloudfront_distribution" "main" {
  default_root_object = "index.html"  // When end user requests the root url this object is returned
  enabled             = true          // Accept end user requests or not
  is_ipv6_enabled     = true          // Enable ipv6 - More efficient routing without fragmenting packets
  wait_for_deployment = true          // Default is true so this can be omitted

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]             // HTTP methods that are processed and forwarded to S3
    cached_methods         = ["GET", "HEAD", "OPTIONS"]             // Which HTTP method responses should be cached
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" // CachingOptimized policy
    target_origin_id       = aws_s3_bucket.main.bucket              // Routes requests to S3 bucket
    viewer_protocol_policy = "redirect-to-https"                    // Defines which protocol can be used to access files in the S3 bucket
  }

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name // DNS domain name of S3 bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = aws_s3_bucket.main.bucket
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" // Content can be accessed from anywhere
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true // Using CloudFront domain name therefore the default certificate is chosen
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "s3-cloudfront-origin-access-main"
  origin_access_control_origin_type = "s3"      // Type of origin the OAC is valid for
  signing_behavior                  = "always"  // Authenticates at every request
  signing_protocol                  = "sigv4"   // Determines how CloudFront authenticates requests
}

data "aws_iam_policy_document" "cloudfront_oac_access" {
  statement {
    // Specifies that cloudfront is allowed to access the S3 bucket.
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"  // Allowed action
    ]

    resources = ["${aws_s3_bucket.main.arn}/*"] // The statement covers this object

  // Conditions for when the policy is active
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id                                    // Which bucket to attach the policy to
  policy = data.aws_iam_policy_document.cloudfront_oac_access.json  // The actual policy
}