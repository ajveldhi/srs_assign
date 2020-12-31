variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "./modules/ec2/mykey.pub"
}

variable "ami_id" {
  default = "ami-0817d428a6fb68645"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_count" {
  default = "5"
}



