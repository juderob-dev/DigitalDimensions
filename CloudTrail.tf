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
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "arn:aws:sns:us-west-2:432981146916:user-updates-topic"
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:us-west-2:432981146916:terraform-queue-too"
}
variable "lambda_function_name" {
  default = "lambda_function_name"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = var.lambda_function_name

  # ... other configuration ...
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}