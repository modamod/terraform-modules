variable "create_public_subnets" {
    type = bool
    description = "Flag to enable public subnet creations, defaults to true"
    default = true
}

variable "create_private_subnets" {
    type = bool
    description = "Flag to enable/disable private subnets creation, defaults to false "
    default = false
}
variable "create_nat_gateway" {
  type = bool
  description = "Flag to enable/disable nat gateway for private subnets. defaults to false."
  default = false
}

variable "azs" {
  type = list(string)
  description = "List of Azs to create subnets in."
}

variable "cidr_block" {
    type = string
    description = "VPC cidr block to use, defaults to 10.0.0.0/16"
    default = "10.0.0.0/16"
}
variable "tags" {
    type = map(string)
    description = "Map of tags for resource that supprts it."

}
