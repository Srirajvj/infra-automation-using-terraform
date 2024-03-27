provider "aws" {
  profile = "sriraj"
  region = "${var.region}"
}

resource "aws_security_group" "webserver_sg" {
  name = "webserver_sg"
  description = "This is the webserver security group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name="allow_http"
  }
}

resource "aws_instance" "webserver_1" {
  ami = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id_1}"
  vpc_security_group_ids = ["${aws_security_group.webserver_sg.id}"]

  tags = {
    name="webserver1"
  }

  user_data = "${file("userdata.sh")}"
}

resource "aws_lb_target_group" "web_tg" {
  name = "webtg"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = "${aws_lb_target_group.web_tg.arn}"
  target_id = "${aws_instance.webserver_1.id}"
  port = 80
}

resource "aws_lb" "web_lb" {
  name = "weblb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.webserver_sg.id}"]
  subnets = ["${var.subnet_id_1}","${var.subnet_id_2}"]

  tags = {
    name = "production"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = "${aws_lb.web_lb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.web_tg.arn}"
  }
}