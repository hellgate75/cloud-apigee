resource "aws_directory_service_directory" "simple-ad" {
  name = "${var.ad-krb-realm}"
  password = "${var.ad-password}"
  size = "Small"
  type = "${var.ad-type}"

  vpc_settings {
    vpc_id = "${aws_vpc.core.id}"
    subnet_ids = ["${aws_subnet.internal.id}", "${aws_subnet.public.id}"]
  }
}

# Need a way to get the security group created by the directory service
# so that we can open it up to convox if added
# https://github.com/hashicorp/terraform/issues/5750
output "directory-security-group-id" {
  value = "${aws_directory_service_directory.simple-ad.id}"
}

output "ad-dns-1" {
  value = "${element(aws_directory_service_directory.simple-ad.dns_ip_addresses, 0)}"
}

output "ad-dns-2" {
  value = "${element(aws_directory_service_directory.simple-ad.dns_ip_addresses, 1)}"
}
