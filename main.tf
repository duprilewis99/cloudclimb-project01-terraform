terraform {
  backend "s3" {
    bucket       = "cloudclimb-project01-tfstate-511126655924-us-east-2-an"
    key          = "cloudclimb-project01/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name        = "cloudclimb-project01-vpc"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name        = "cloudclimb-project01-app-a"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name        = "cloudclimb-project01-app-b"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name        = "cloudclimb-project01-data-a"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}

resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name        = "cloudclimb-project01-data-b"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_subnet" "management_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name        = "cloudclimb-project01-management-a"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_subnet" "management_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.22.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name        = "cloudclimb-project01-management-b"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "cloudclimb-project01-igw"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name        = "cloudclimb-project01-public-rt"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_route_table_association" "app_a_public" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "app_b_public" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "cloudclimb-project01-private-rt"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}


resource "aws_route_table_association" "data_a_private" {
  subnet_id      = aws_subnet.data_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data_b_private" {
  subnet_id      = aws_subnet.data_b.id
  route_table_id = aws_route_table.private.id


}


resource "aws_route_table_association" "management_a_private" {
  subnet_id      = aws_subnet.management_a.id
  route_table_id = aws_route_table.private.id


}

resource "aws_route_table_association" "management_b_private" {
  subnet_id      = aws_subnet.management_b.id
  route_table_id = aws_route_table.private.id
}




resource "aws_security_group" "app" {
  name        = "cloudclimb-project01-app-sg"
  description = "security group for CloudClimb Project 01 application resources"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudclimb-project01-app-sg"
    Environment = "Dev"
    Project     = "CloudClimb-Project01"
  }
}

resource "aws_security_group" "ssh" {
  name        = "cloudclimb-project01-ssh-sg"
  description = "Security group for SSH access to CloudClimb Project 01 EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["47.248.143.56/32"]
  }
  #memos
  ingress {
    description = "Memos access from my current public IP"
    from_port   = 5230
    to_port     = 5230
    protocol    = "tcp"
    cidr_blocks = ["47.248.143.56/32"]

  }
  #outbound traffic

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudclimb-project01-ssh-sg"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"
  }
}

resource "aws_key_pair" "cloudclimb" {
  key_name   = "cloudclimb-project01-key"
  public_key = var.public_key
  #public_key = file(pathexpand("~/.ssh/cloudclimb-project01.pub"))

  tags = {
    Name        = "cloudclimb-project01-key"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.app_a.id
  associate_public_ip_address = true


  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]

  key_name = aws_key_pair.cloudclimb.key_name

  tags = {
    Name        = "cloudclimb-project01-app"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"

  }

  lifecycle {
    ignore_changes = [ami]
  }

}

resource "aws_db_subnet_group" "main" {
  name        = "cloudclimb-project01-db-subnet-group"
  description = "Private database subnets for CloudClimb Project01"

  subnet_ids = [
    aws_subnet.data_a.id,
    aws_subnet.data_b.id,
  ]

  tags = {
    Name        = "cloudclimb-project01-db-subnet-group"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"
  }
}


resource "aws_security_group" "rds" {
  name        = "cloudclimb-project01-rds-sg"
  description = "Allow PostgreSQL from the application security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from application EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cloudclimb-project01-rds-sg"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"
  }
}


variable "db_password" {
  description = "Password for the CloudClimb PostgreSQL database"
  type        = string
  sensitive   = true
}


resource "aws_db_instance" "postgres" {
  identifier        = "cloudclimb-project01-postgres"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "memos"
  username = "memosadmin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  storage_encrypted          = true
  backup_retention_period    = 0
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  deletion_protection        = false

  tags = {
    Name        = "cloudclimb-project01-postgres"
    Project     = "CloudClimb-Project01"
    Environment = "Dev"
  }
}


variable "public_key" {
  description = "SSH public key for the EC2 key pair"
  type        = string
}
