provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

module "vpc" {
  source    = "../modules/vpc"
  stack_name          = "web"
  environment  ="development"
  vpc_cidr          = "${var.web_vpc_cidr}"
  public_subnets = ["${var.public_subnet1}","${var.public_subnet2}"]
  private_subnets = ["${var.private_subnet1}","${var.private_subnet2}"]
  region = "${var.region}"
  key_name                    = "${var.key_name}"
}

resource "aws_instance" "web" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.web_instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_ids[0]}"
  private_ip                  = "${var.web_instance_ips[count.index]}"
  user_data                   = "${file("files/web_bootstrap.sh")}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]
  tags {
    Name = "web-${format("%03d", count.index + 1)}"
  }
  count = "${length(var.web_instance_ips)}"
}

resource "aws_instance" "app" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.app_instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.private_subnet_ids[0]}"
  private_ip                  = "${var.app_instance_ips[count.index]}"
  user_data                   = "${file("files/app_bootstrap.sh")}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.app_inbound_sg.id}",
  ]
  tags {
    Name = "app-${format("%03d", count.index + 1)}"
  }
  count = "${length(var.app_instance_ips)}"
}

resource "aws_instance" "rdb" {
  ami                         = "${lookup(var.ami, var.region)}"
  instance_type               = "${var.db_instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.private_subnet_ids[1]}"
  private_ip                  = "${var.db_instance_ips[count.index]}"
  user_data                   = "${file("files/db_bootstrap.sh")}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.db_inbound_sg.id}",
  ]
  tags {
    Name = "db-${format("%03d", count.index + 1)}"
  }
  count = "${length(var.db_instance_ips)}"
}

resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = ["${module.vpc.public_subnet_ids}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = ["${aws_instance.web.*.id}"]
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SGs for the App server
resource "aws_security_group" "app_inbound_sg" {
  name        = "app_inbound"
  description = "Allow SSH, HTTP/S from Web Servers only"
  vpc_id      = "${module.vpc.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
  }
  ingress {
    from_port   = 443 
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
  }
 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
  }
 ingress {
   from_port   = 8
   to_port     = 0
   protocol    = "icmp"
   cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

#SGs for the DB server(s)
resource "aws_security_group" "db_inbound_sg" {
  name        = "db_inbound"
  description = "Allow SSH, TCP from Web, App Servers only"
  vpc_id      = "${module.vpc.vpc_id}"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
  }
 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
  }
 ingress {
   from_port   = 8
   to_port     = 0
   protocol    = "icmp"
   cidr_blocks = ["${var.public_subnet1}","${var.public_subnet2}","${var.private_subnet1}","${var.private_subnet2}"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
