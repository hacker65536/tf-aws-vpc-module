
resource "aws_vpc" "vpc" {
  cidr_block          = var.use_ipam_pool ? null : var.vpc_cidr_block
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-vpc"
      //     Name = "${local.tags.Project}-${local.tags.Stage}"
    },
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-igw"
    },
  )
}

resource "aws_subnet" "subnet" {
  for_each          = local.s_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-${each.value.name}"
    },
  )
}

resource "aws_eip" "ngw_eip" {
  for_each = toset(local.azs)
  tags = {
    Name = "${local.prefix}-ngw-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = {
    for k, v in aws_subnet.subnet : k => v
    if strcontains(k, "public")
    //   if strcontains(k, "nat")
  }
  allocation_id = aws_eip.ngw_eip[each.value.availability_zone].id
  subnet_id     = aws_subnet.subnet[each.key].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-ngw-${each.key}"
    },
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-public-rt"
    },
  )
}

resource "aws_route_table" "private_route_table" {
  for_each = toset(local.azs)
  vpc_id   = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-private-rt-${each.key}"
    },
  )
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route" {
  for_each = {
    for k, v in aws_subnet.subnet : k => v
    if strcontains(k, "public")
  }
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route" {
  for_each = {
    for k, v in aws_subnet.subnet : k => v
    if strcontains(k, "private")
  }
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.private_route_table[each.value.availability_zone].id
}

resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  count = var.create_cache_subnet_group ? 1 : 0
  name  = "${local.prefix}-cache-subnet-group"
  subnet_ids = [
    for k, v in aws_subnet.subnet : v.id
    if strcontains(k, "private-cache")
  ]
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-cache-subnet-group"
    },
  )
  depends_on = [aws_subnet.subnet]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count = var.create_db_subnet_group ? 1 : 0
  name  = "${local.prefix}-db-subnet-group"
  subnet_ids = [
    for k, v in aws_subnet.subnet : v.id
    if strcontains(k, "private-db")
  ]

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-db-subnet-group"
    },
  )
  depends_on = [aws_subnet.subnet]
}

##output "out" {
##  value = {
##    for k, v in aws_subnet.subnet : k => v
##    if strcontains(k, "private")
##  }
##}
#

