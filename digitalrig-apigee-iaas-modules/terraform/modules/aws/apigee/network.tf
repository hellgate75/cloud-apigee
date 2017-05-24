resource "aws_vpc" "core" {
  cidr_block = "${var.vpc-net-cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  tags {
    Name = "${var.ansible-domain}"
  }
}

output "default-vpc-id" {
  value = "${aws_vpc.core.id}"
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.core.id}"
  cidr_block = "${var.public-net-cidr}"
  map_public_ip_on_launch = 1
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "${var.ansible-domain}-public"
  }
  availability_zone = "${var.region}${var.public-availability-zone}"
}

resource "aws_subnet" "internal" {
  vpc_id = "${aws_vpc.core.id}"
  cidr_block = "${var.internal-net-cidr}"
  tags {
    Name = "${var.ansible-domain}-internal"
  }
  availability_zone = "${var.region}${var.internal-availability-zone}"
}

output "private-subnet-id" {
  value = "${aws_subnet.internal.id}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.core.id}"
  tags {
    Name = "${var.ansible-domain}-default"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.core.id}"

  /*route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "${aws_internet_gateway.default.id}"
  }*/
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.ansible-domain}-public"
  }
}

resource "aws_route_table" "internal" {
  vpc_id = "${aws_vpc.core.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
  tags {
    Name = "${var.ansible-domain}-internal"
  }
}

output "public-route-table-id" {
  value = "${aws_route_table.public.id}"
}

output "internal-route-table-id" {
  value = "${aws_route_table.internal.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "internal" {
  subnet_id = "${aws_subnet.internal.id}"
  route_table_id = "${aws_route_table.internal.id}"
}

resource "aws_security_group" "default" {
  name = "${var.ansible-domain}-default"
  description = "${var.ansible-domain}-default"
  vpc_id = "${aws_vpc.core.id}"
  depends_on = ["aws_vpc_dhcp_options_association.default"]
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["217.138.56.186/32"] # TODO: limit this?
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.public-net-cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.public-net-cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.ansible-domain}-default"
  }
}

resource "aws_security_group" "ovpn" {
  name = "${var.ansible-domain}-ovpn"
  description = "${var.ansible-domain}-ovpn"
  vpc_id = "${aws_vpc.core.id}"
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: limit this?
  }

  # keep it wide open because it is locked by iptables by default (knockd opens it by request)
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.vpn-knock-lower-port}"
    to_port = "${var.vpn-knock-upper-port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }
  ingress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.default.id}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.default.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.ansible-domain}-ovpn"
  }
}

output "default-security-group-id" {
  value = "${aws_security_group.default.id}"
}

resource "aws_vpc_dhcp_options" "default" {
  domain_name = "${var.krb-domain}"
  domain_name_servers = ["${aws_directory_service_directory.simple-ad.dns_ip_addresses}", "${var.internal-net-prefix}.2"]

  tags {
    Name = "${var.ansible-domain}-default"
  }
}

resource "aws_vpc_dhcp_options_association" "default" {
  vpc_id = "${aws_vpc.core.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

resource "aws_route53_zone" "internal-zone" {
  name = "riglet"
  comment = "APIGee Sampler Zone (${var.ansible-domain})(region:${var.region})"
  vpc_id = "${aws_vpc.core.id}"
}

output "route53-internal-zone-id" {
  value = "${aws_route53_zone.internal-zone.id}"
}

output "default_security_group_id" {
  value = "${aws_security_group.default.id}"
}
