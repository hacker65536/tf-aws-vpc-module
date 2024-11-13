variable "prefix" {
  type = string
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "max_azs" {
  type    = number
  default = 3
}

variable "tags" {
  type = map(string)
}
variable "azs" {
  type    = list(string)
  default = []
}

variable "use_ipam_pool" {
  description = "Determines whether IPAM pool is used for CIDR allocation"
  type        = bool
  default     = false
}

variable "create_db_subnet_group" {
  description = "Determines whether to create a DB subnet group"
  type        = bool
  default     = false

}
variable "create_cache_subnet_group" {
  description = "Determines whether to create a cache subnet group"
  type        = bool
  default     = false
}

variable "ipv4_ipam_pool_id" {
  description = "(Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR"
  type        = string
  default     = null
}

variable "ipv4_netmask_length" {
  description = "(Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id"
  type        = number
  default     = null
}


variable "subnet_cidr" {
  type = map(object({
    prefix  = string
    newbits = number
  }))
  default = {

    public = {
      prefix  = "10.222.0.0/24"
      newbits = 2
    }
    private = {
      prefix  = "10.222.8.0/21"
      newbits = 2
    }
    private-db = {
      prefix  = "10.222.1.0/24"
      newbits = 2
    }
    private-cache = {
      prefix  = "10.222.2.0/24"
      newbits = 2
    }
  }

}
