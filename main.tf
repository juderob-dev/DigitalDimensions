terraform{
    backend "s3"{
        bucket="<bucket name >"
        key="<key>"
        region="us-east 1"
    }
}
provider "aws" {
    version ="~>3.0"
  
    region = "us-east-1"
}
resource "<provider>_<resource_type>""name"{
    config options.....
    key ="value"
    ley2= "another value"
}