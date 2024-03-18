provider "aws" {
    region  = "ap-northeast-1"
    
    default_tags {
        tags = {
            creator = "yutaro.shirayama"
            terraform = "true"
        }
    }
}