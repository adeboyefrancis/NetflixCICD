#####################################
# Variables for Deployment
#####################################
variable "prefix" {
  type    = string
}

variable "project_name" {
  type = string
}

variable "owner_name" {
  type = string

}

variable "managed_by" {
  type = string

}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}