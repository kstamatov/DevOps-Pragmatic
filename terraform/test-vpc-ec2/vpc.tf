data "aws_availability_zones" "available" {
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "test-private" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "test-private"
  }
}

resource "aws_subnet" "test-private-2" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "test-private-2"
  }
}

resource "aws_subnet" "test-public" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "test-public"
  }
}

resource "aws_subnet" "test-public-2" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "test-public-2"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_eip" "eip2" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.test-public.id

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "nat-gw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.test-public-2.id

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "subnet-RT" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "subnet-2-RT" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }
 depends_on = [aws_nat_gateway.nat-gw]
}

resource "aws_route_table" "subnet-3-RT" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw2.id
  }
 depends_on = [aws_nat_gateway.nat-gw2]
}

resource "aws_route_table_association" "public-RT-AS" {
  subnet_id      = aws_subnet.test-public.id
  route_table_id = aws_route_table.subnet-RT.id
 depends_on = [aws_route_table.subnet-RT]
}

resource "aws_route_table_association" "public-2-RT-AS" {
  subnet_id      = aws_subnet.test-public-2.id
  route_table_id = aws_route_table.subnet-RT.id
  depends_on = [aws_route_table.subnet-RT]
}

resource "aws_route_table_association" "private-RT-AS" {
  subnet_id      = aws_subnet.test-private.id
  route_table_id = aws_route_table.subnet-2-RT.id
  depends_on = [aws_route_table.subnet-2-RT]
}

resource "aws_route_table_association" "private-2-RT-AS" {
  subnet_id      = aws_subnet.test-private-2.id
  route_table_id = aws_route_table.subnet-3-RT.id
    depends_on = [aws_route_table.subnet-3-RT]
}


resource "aws_security_group" "sg-1" {
  name        = "first-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "sg-2" {
  name        = "second-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
