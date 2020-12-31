resource "aws_elb" "my-elb" {
  name            = "my-elb"
  subnets         = [module.my_ec2.main-public-1.id]
  security_groups = [module.my_ec2.elb-securitygroup.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400
  instances                   = module.my_ec2.instance_ids
  tags = {
    Name = "my-elb"
  }
}

