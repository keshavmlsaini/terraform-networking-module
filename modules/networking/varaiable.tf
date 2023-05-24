# variable "subnet_count" {
#   default = 2
# }
variable "public_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "vpc" {
  default = "10.0.0.0/16"
}