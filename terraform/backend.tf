terraform {
    backend "s3" {
        bucket         = "shirayama-test-terraform-tfstate"
        key            = "aws-eks/terraform.tfstate"
        encrypt        = true
        region         = "ap-northeast-1"
    }
}