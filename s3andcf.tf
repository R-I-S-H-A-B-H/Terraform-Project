resource "aws_s3_bucket" "rishabhs-bucket" {
	bucket = "rishabhs-bucket"
	acl    = "publi-read-write"
	region = "ap-south-1"	
	
	tags = {
		Name = "S3-Bucket"
	}
}


locals {
	s3_origin_id = "s3-origin"
}

resource "aws_s3_bucket_object" "Object1" {
	depends_on = [aws_s3_bucket.rishabhs-bucket,]

	bucket = "rishabhs-bucket"
	key    = "s3image.jpeg"
	source = "C:/Users/rishabh kalyani/Pictures/Wallpapers/s3image.jpeg"
	etag = filemd5("C:/Users/rishabh kalyani/Pictures/Wallpapers/s3image.jpeg")
}

resource "aws_s3_bucket_public_access_block" "public_storage" {
	depends_on = [aws_s3_bucket.rishabhs-bucket,]

	bucket = "rishabhs-bucket"
	block_public_acls = false
	block_public_policy = false
}

resource "aws_cloudfront_distribution" "mydistribution" {
	origin {
		domain_name = aws_s3_bucket.rishabhs-bucket.bucket_regional_domain_name
		origin_id   = local.s3_origin_id
	}

	enabled             = true
  	is_ipv6_enabled     = true
  	comment             = "This is my Distribution"

	default_cache_behavior {
    		allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
	    	cached_methods   = ["GET", "HEAD"]
    		target_origin_id = local.s3_origin_id

    		forwarded_values {
      			query_string = false

      			cookies {
        			forward = "none"
      			}
    		}

	    	viewer_protocol_policy = "allow-all"
    		min_ttl                = 0
    		default_ttl            = 3600
    		max_ttl                = 86400
		compress               = true
	}

  	restrictions {
    	geo_restriction {
      		restriction_type = "none"
    		}
	}

  	viewer_certificate {
    		cloudfront_default_certificate = true
  		}
	tags = {
    		Name = "S3-Distribution"
  	}
}
















