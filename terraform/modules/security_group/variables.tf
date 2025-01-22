variable "prefix" {
  type        = string
  description = "The prefix of resource name"
}

variable "suffix" {
  type        = string
  description = "The suffix of resource name"
}

variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "sg_rule_ingress" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
  description = "The ingress rules of security group"
}
