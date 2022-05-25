data"aws_caller_identity""current"{}
resource "aws_iam_role" "cloudtrail_cqpocsrole"{
    name = "cloudtrail-to-cloudwatch"
    assume_role_policy= <<EOF
    {
        "Version":"2012=10=17",
        "Statement":[
            {
                "Effect":"Allow"
                "Principal":{
                    "Service":"cloudtrail.amazonaws.com"
                },
                "Action":"sts:AssumRole"
            }
        ]
    }
}
EOF
}
resource "aws_iam_role_policy""cloudtrail_cqpocsrolepolicy"{
    name="cloudtrail-policy"
    role=aws_iam_role.cloudtrail_cqpocsrole.id
    policy= <<EOF
    {
        "Version":"2012-10-17",
        "Statement":[{
            "Sid":"AWSCloudTrailCreateLogStream",
            "Effect":"Allow",
            "Action":["logs:CreateLogStream"],
            "Resources":["arn:aws:logs:us-east-1:818934363094:log-group:${aws_cloudwatch_log_group.awss3bucketloggroups.id}:*"]
        

        },
        {
            "Sid":"AWSCloudTrailPutLogEvents",
            "Effect":"Allow",
            "Action":["logs:PutLogEvents"],
            "Resources":[
                "arn:aws:logs:us-east-1:818934363094:log-group:${aws_cloudwatch_log_group.awss3bucketloggroups.id}:*"
            ]
        }
        ]
            
    }
    EOF
    

}
resource "aws_cloudtrail_log_group" "awss3bucketloggroups" {
    name= "log-stream"
  
}
resource "aws_cloudtrail" "cloudtrailcqpocs"{
    name="tf-based-cloud-trail"
    s3_bucket_name = aws_s3_bucket.cqpocs.id
    s3_key_prefix = "cloudtrailkey"
    include_global_service_events = "arn:aws:logs:us-east-1:818934363094:log-group:${aws_cloudwatch_log_group.awss3bucketloggroups.id}:*"
    event_selector {
      read_write_type="All"
      include_management_events=true
    }
    cloud_watch_logs_role_arn = "${aws_iam_role.cloudtrail_cqpocsrole.arn}"
}
resource "aws_s3_bucket" "cqpocs" {
    bucket="tf-DD-trail-bucket-cqpocs"
    force_destroy = true
    policy = <<POLICY
    {
        "Version":"2012-10-17",
        "Statement":
        [
            {
                "Sid":"AWSCloudTrailAclCheck",
                "Effect":"Allow"
                "Principal":{
                    Service":"cloudtrail.amazonaws.com"
                    },
                "Action":"s3:GetBucketAc1",
                "Resources":[
                    "arn:aws:s3:::tf-DD-trail-bucket-cqpocs"
                ]
            },
            {
                "Sid":"AWSCloudTrailWrite",
                "Effect":"Allow",
                "Pricipal":{
                    Service":"cloudtrail.amazonaws.com"
                    },
                "Action":"s3:PutObject",

                "Resources":"arn:aws:s3:::tf-DD-trail-bucket-cqpocs/cloudtrailkey/AWSlogs/${data.aws_caller_identity.current}/*"
                "Condition": {
                    "StringEquals": {
                        "s3:x-amz-acl": "bucket-owner-full-control"
                   
                    }
                }
            }
             
        ]
        
    }
 POLICY 
}
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  metric_query {
    id="e1"
    expression = 

    
  }
}
resource "aws_cloudwatch_log_metric_filter" "yada" {
  name           = "MyAppAccessCount"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = aws_cloudwatch_log_group.dada.name

  metric_transformation {
    name      = "EventCount"
    namespace = "YourNamespace"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_group" "dada" {
  name = "MyApp/access.log"
}
resource "aws_sns_topic" "test" {
  name = "my-topic-with-policy"
}
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.test.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account-id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.test.arn,
    ]

    sid = "__default_statement_ID"
  }
}