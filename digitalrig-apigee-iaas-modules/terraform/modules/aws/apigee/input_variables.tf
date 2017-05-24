variable "region"               {  }
variable "vpc-net-cidr"         {  }
variable "public-net-cidr"         {  }
variable "public-availability-zone"{  }
variable "internal-net-cidr"    {  }
variable "internal-net-prefix"  {  }
variable "internal-availability-zone" {}
variable "ansible-domain"       {  }
variable "ansible-inventory"    { default = "riglet-apigee" }

variable "route-53-domain-id"   {  }
variable "subnets"              { default = "['10.10.0.0 255.255.0.0']" }

variable "ad-type"         {  }

# Ideally, the kerberos realm should be set to the uppercase of the Domain
variable "ad-krb-realm"         {  }
variable "krb-domain"           {  }
variable "base-dn"              {  }
variable "ad-password"          {  }

variable "keypair"              {  }
variable "internal-keypair"     {  }

variable "digitalrig-riglet-ref" { default = "master" }
variable "dr-scripts-ref" { default = "master" }
variable "platform-ref" { default = "master" }

# override ami if needed, leave empty to use default mapping
variable "nat-ami" { default = "" description = "custom nat ami to use" }
variable "linux-ami" { default = "" description = "custom linux ami to use" }
variable "default-linux-ami" { type = "map" description = "default ec2 region to linux ami mapping" }
variable "windows-ami" { default = "" description = "custom windows ami to use" }

# knockd port range
variable "vpn-knock-lower-port" { }
variable "vpn-knock-upper-port" { }
