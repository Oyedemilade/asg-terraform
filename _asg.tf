# Launch configuration
# Configures the machines that are deployed
#
resource "aws_launch_configuration" "launch_config" {
  name                        = "${var.launch-config-name}"
  image_id                    = "${var.instance-ami}"
  instance_type               = "${var.instance-type}"
  iam_instance_profile        = "${var.iam-role-name != "" ? var.iam-role-name : ""}"
  key_name                    = "${var.instance-key-name != "" ? var.instance-key-name : ""}"
  user_data                   = "${var.user-data-script != "" ? file("${var.user-data-script}") : ""}"
  associate_public_ip_address = "${var.instance-associate-public-ip}"                                  
  security_groups             = ["${aws_security_group.sg.id}"]
}

# AutoScaling Group
# Scale (up/down) the number of machines, based on some criteria
#
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.asg-name}"
  min_size                  = "${var.asg-min-size}"
  desired_capacity          = "${var.asg-def-size}"
  max_size                  = "${var.asg-max-size}"
  launch_configuration      = "${aws_launch_configuration.launch_config.name}"
  vpc_zone_identifier       = ["${aws_subnet.subnet-1.id}", "${aws_subnet.subnet-2.id}"]
  target_group_arns         = ["${aws_lb_target_group.lb_target.arn}"]
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
}

# AutoScaling Attachment
# Wraps the ASG machines in a target group for the load balancer
#
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.lb_target.arn}"
}
