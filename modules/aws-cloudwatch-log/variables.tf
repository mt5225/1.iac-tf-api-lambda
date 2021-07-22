variable "name" {
  type        = string
  description = "log group name"
}

variable "retention_in_days" {
  type    = number
  default = 7
}

variable "tags" {
  type    = map(any)
  default = {}
}
