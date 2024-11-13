locals {
  tags           = var.tags
  vpc_cidr_block = var.vpc_cidr_block
  max_azs        = var.max_azs

  azs         = length(var.azs) == 0 ? slice(data.aws_availability_zones.azs.names, 0, var.max_azs) : var.azs
  prefix      = var.prefix
  subnet_cidr = var.subnet_cidr


  // subnet_cidr から subnet map 用の中間データを作成 
  s = {
    for k, v in local.subnet_cidr : k => [
      for i in range(0, length(local.azs)) : {
        name = "${k}-${substr(local.azs[i], -2, -1)}"
        cidr = cidrsubnet(v.prefix, v.newbits, i)
        az   = local.azs[i]
      }
    ]
  }

  // subnet map 
  s_map = {
    for k, v in flatten(values(local.s)) : v.name => {
      name = v.name
      cidr = v.cidr
      az   = v.az
    }
  }
}
