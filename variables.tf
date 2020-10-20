variable "name" { }
variable "region" { }
variable "rg" { }
variable "vnet" { }
variable "subnet" { }
variable "ssh_key" { }
variable "aws_access_key" { }
variable "aws_secret_key" { }

variable "aws_region" {
  default = "eu-central-1"
}
variable "instance_size" {
  default = "Standard_B1ls"
}
variable "num_vms" {
  default = 1
}
variable "domain_name" {
  default = "avxlab.de"
}