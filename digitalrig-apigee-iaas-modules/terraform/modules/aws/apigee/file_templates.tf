#####################################################
# client templates
###
data "template_file" "client_cloud_config" {
  template = "${file("${path.module}/../common/templates/cloudinit_client_template.template")}"
  vars {
    ad-domain = "${var.krb-domain}"
    subnets = "${var.subnets}"
    region = "${var.region}"
    ansible-domain = "${var.ansible-domain}"
    ad-domain = "${var.krb-domain}"
    ad-password = "${var.ad-password}"
    ad-krb-realm = "${var.ad-krb-realm}"
    base-dn = "${var.base-dn}"
    dr-scripts-ref = "${var.dr-scripts-ref}"
    digitalrig-riglet-ref = "${var.digitalrig-riglet-ref}"
    platform-ref = "${var.platform-ref}"
  }
}

#####################################################
# heart templates
###
data "template_file" "heart_cloud_config" {
  template = "${file("${path.module}/../common/templates/cloudinit_heart_template.template")}"
  vars {
    subnets = "${var.subnets}"
    region = "${var.region}"
    ansible-domain = "${var.ansible-domain}"
    ad-domain = "${var.krb-domain}"
    ad-password = "${var.ad-password}"
    ad-krb-realm = "${var.ad-krb-realm}"
    base-dn = "${var.base-dn}"
    aws_dns_1 = "${element(aws_directory_service_directory.simple-ad.dns_ip_addresses, 0)}"
    aws_dns_2 = "${element(aws_directory_service_directory.simple-ad.dns_ip_addresses, 1)}"
    aws_dns_3 = "${var.internal-net-prefix}.2"
    ansible-inventory = "${var.ansible-inventory}"
    dr-scripts-ref = "${var.dr-scripts-ref}"
    digitalrig-riglet-ref = "${var.digitalrig-riglet-ref}"
    platform-ref = "${var.platform-ref}"
  }
}
