variable "env" {
  type = string
}

variable "prefix_env" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "ecr" {
  type = list(object({
    repository_name                   = string
    repository_read_write_access_arns = list(string)
    repository_lifecycle_policy       = string
  }))
}