variable "access_key" {
     description = "AWS access key."
     default = "AKIASCOOBYDOOBYD00"
}

variable "web_vpc_cidr" {
  description = "The VPC CIDR"
  default = "192.168.0.0/16" 
}

variable "public_subnet1" {
 description = "Public Subnet #1"
 default = "192.168.101.0/24"
}
variable "public_subnet2" {
 description = "Public Subnet #2"
 default = "192.168.102.0/24"
}
variable "private_subnet1" {
 description = "Private Subnet #1"
 default = "192.168.1.0/24"
}
variable "private_subnet2" {
 description = "Database Subnet/Private Subnet #2"
 default = "192.168.2.0/24"
}

variable "secret_key" {
    description = "AWS secret key."
    default = "OMMANEPADMEOM"
}

variable "region" {
    description = "default AWS region."
    default = "eu-west-1"
}

variable "ami" {
  type    = "map"
  default = {
    eu-central-1 = "ami-5055cd3f"
    eu-west-1    = "ami-1b791862"
    us-west-2    = "ami-32e7464a"
    us-east-1    = "ami-66506c1c"
  }
  description = "AMI IDs for Ubuntu 16.04 in various regions"
}

variable "base_instance_type" {
  default     = "t2.micro"
  description = "default instance type for base infrastructure"
}

variable "web_instance_type" {
  default     = "t2.micro"
  description = "The Web instance type to launch "
}

variable "app_instance_type" {
  default     = "t2.micro"
  description = "The app instance type to launch "
}

variable "db_instance_type" {
  default     = "t2.large"
  description = "The app instance type to launch "
}

variable "web_instance_ips" {
     description = "The IPs to use for our web instances"
     default = ["192.168.101.21"]
}

variable "app_instance_ips" {
     description = "The IPs to use for our app instances"
     default = ["192.168.1.21"]
}

variable "db_instance_ips" {
     description = "The IPs to use for our DB instances"
     default = ["192.168.2.21"]
}

variable "key_name" {
    description = "The AWS SSH key pair to use for EC2 instance resources."
    default="osadmin"
}
