provider "aws" {
  region = var.region
}

data "aws_availability_zones" "a_z" {}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu_1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sg.id]
  user_data       = var.user_data
  subnet_id       = aws_default_subnet.subnet_a.id
  key_name        = var.key_pair

  tags = {
    Name = "ubuntu_1"
  }
}

resource "aws_instance" "ubuntu_2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sg.id]
  user_data       = var.user_data
  subnet_id       = aws_default_subnet.subnet_b.id
  key_name        = var.key_pair

  tags = {
    Name = "ubuntu_2"
  }
}
#------------------------------------------------------------------------------------
resource "aws_security_group" "sg" {
  description = "allow http, ssh"
  #vpc_id      = aws_default_vpc.m.id

  dynamic "ingress" {
    for_each = var.allow_tcp_ports
    content {
      description = "dev-ports"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#------------------------------------------------------------------------------------
resource "aws_default_vpc" "m" {}

resource "aws_default_subnet" "subnet_a" {
  availability_zone = data.aws_availability_zones.a_z.names[0]
  tags = {
    Name = "Default subnet 1"
  }
}

resource "aws_default_subnet" "subnet_b" {
  availability_zone = data.aws_availability_zones.a_z.names[1]
  tags = {
    Name = "Default subnet 2"
  }
}
#------------------------------------------------------------------------------------

resource "aws_lb" "app" {
  name                             = "app-lb"
  internal                         = false
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  security_groups                  = [aws_security_group.sg.id]
  subnets                          = [aws_default_subnet.subnet_a.id, aws_default_subnet.subnet_b.id]

  enable_deletion_protection = false

  tags = {
    Name = var.load_balancer_name
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.m.id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "instances" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ubuntu_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ubuntu_2.id
  port             = 80
}
#---------------------------------------------------------------------------------
output "lb_url" {
  value = aws_lb.app.dns_name
}
