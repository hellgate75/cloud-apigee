variable "region" {}
variable "vpc-net-cidr" {}
variable "public-net-cidr" {}
variable "public-availability-zone" {}
variable "internal-net-cidr" {}
variable "internal-net-prefix" {}
variable "internal-availability-zone" {}
variable "ansible-domain" {}

# ID of the route53 domain that should be used for the VPN
variable "route-53-domain-id" {} // mapping to riglet.io route53. Change as necessary
variable "ad-type" {}

# Ideally, the kerberos realm should be set to the uppercase of the Domain -- this is only used internally to the VPC
variable "ad-krb-realm" {}
variable "krb-domain" {}
variable "base-dn" {}
variable "ad-password" {}

# Change this based on the region
variable "keypair" {}
variable "internal-keypair" {}
# > Uncomment in case you need to use custom image
# > See default-linux-ami in ./variables for region-to-ami mapping
# variable "linux-ami"          {}

variable "dr-scripts-ref" {}
variable "digitalrig-riglet-ref" {}

#todo: need to merge rig-2.0 to master?
variable "platform-ref" {}

variable "vpn-knock-lower-port" {}
variable "vpn-knock-upper-port" {}

# convox related input variables
#variable "account-owner-id"      {}
#variable "convox-vpc-id"         {}
#variable "convox-route-table-id" {}
#variable "convox-vpc-net-cidr"   {}
#variable "convox-elb-dns-record" {}
#variable "subnets"               {}
#variable "riglet-directory-security-group-id" {}
