resource "aws_instance" "nat" {
  ami = "${coalesce(var.nat-ami, lookup(var.default-nat-ami, var.region))}"
  # this is a special ami preconfigured to do NAT
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.public.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "nat"
  tags {
    Name = "${var.ansible-domain}-nat"
    Rig = "${var.ansible-domain}"
  }
}

## OVPN box
resource "aws_instance" "ovpn" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
    "${aws_security_group.ovpn.id}"]
  subnet_id = "${aws_subnet.public.id}"
  source_dest_check = false
  associate_public_ip_address = true
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "ovpn")}"
  tags {
    Name = "${var.ansible-domain}-ovpn"
    Role = "ovpn,ad-client"
    Rig = "${var.ansible-domain}"

  }
}

# OpenVPN Public DNS
resource "aws_route53_record" "ovpn-pub" {
  zone_id = "${var.route-53-domain-id}"
  name = "ovpn.ext.${var.ansible-domain}"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ovpn.public_ip}"]
}

output "openvpn-dns" {
  value = "${aws_route53_record.ovpn-pub.fqdn}"
}

# OpenVPN private DNS record
resource "aws_route53_record" "ovpn" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "ovpn"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ovpn.private_ip}"]
}

## Jenkins private
resource "aws_instance" "front-end" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.medium"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
    "${aws_security_group.ovpn.id}"
  ]
  subnet_id = "${aws_subnet.public.id}"
  source_dest_check = false
  associate_public_ip_address = true
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "front-end")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }
  tags {
    Name = "${var.ansible-domain}-front-end"
    Role = "front-end,ad-client"
    Rig = "${var.ansible-domain}"
  }
}

# Jenkins private DNS record
resource "aws_route53_record" "front-end" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "front-end"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.front-end.private_ip}"]
}


output "aws-front-end-private-ip" {
  value = "${aws_instance.front-end.private_ip}"
}

output "aws-front-end-public-ip" {
  value = "${aws_instance.front-end.public_ip}"
}


## Gateway Machine VM
resource "aws_instance" "gateway" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.medium"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
    "${aws_security_group.ovpn.id}"
  ]
  subnet_id = "${aws_subnet.public.id}"
  source_dest_check = false
  associate_public_ip_address = true
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "gateway")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 40
  }
  tags {
    Name = "${var.ansible-domain}-gateway"
    Role = "gateway,ad-client"
    Rig = "${var.ansible-domain}"
  }
}

## Gateway Machine vars
output "aws-gateway-private-ip" {
  value = "${aws_instance.gateway.private_ip}"
}

output "aws-gateway-public-ip" {
  value = "${aws_instance.gateway.public_ip}"
}

## Gateway Machine Route53
resource "aws_route53_record" "gateway" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "gateway"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.gateway.private_ip}"]
}

## Docker CI CD Machine
resource "aws_instance" "docker-ci-cd" {
  ami = "${coalesce(var.linux-ami, lookup(var.default-linux-ami, var.region))}"
  instance_type = "t2.medium"
  key_name = "${var.internal-keypair}"
  iam_instance_profile = "internal-instance"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"
  ]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "docker-ci-cd")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 40
  }
  tags {
    Name = "${var.ansible-domain}-docker-ci-cd"
    Role = "docker-ci-cd,ad-client"
    Rig = "${var.ansible-domain}"
  }
}

## Docker CI CD Machine - vars
output "aws-docker-ci-cd-private-ip" {
  value = "${aws_instance.docker-ci-cd.private_ip}"
}

## Docker CI CD Machine - Route53
resource "aws_route53_record" "docker-ci-cd" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "docker-ci-cd"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.docker-ci-cd.private_ip}"]
}

## windows server box to manage active directory
resource "aws_instance" "ad-admin" {
  ami = "${coalesce(var.windows-ami, lookup(var.default-windows-ami, var.region))}"
  instance_type = "t2.micro"
  key_name = "${var.internal-keypair}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.internal.id}"
  source_dest_check = false
  associate_public_ip_address = false
  user_data = "${replace("${data.template_file.client_cloud_config.rendered}", "REPLACE_HOSTNAME", "ad-admin")}"
  tags {
    Name = "${var.ansible-domain}-ad-admin"
    Role = "windows"
    Rig = "${var.ansible-domain}"
  }
}

output "aws-admin-private-ip" {
  value = "${aws_instance.ad-admin.private_ip}"
}

# windows server box  private DNS record
resource "aws_route53_record" "ad-admin" {
  zone_id = "${aws_route53_zone.internal-zone.id}"
  name = "ad-admin"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.ad-admin.private_ip}"]
}
