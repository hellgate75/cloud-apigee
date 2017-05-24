#todo: more mappings for other regions
variable default-linux-ami {
  type = "map"
  default = {
    us-east-1 = "ami-8ce8b79b"
    us-east-2 = "ami-b87e24dd"
    us-west-2 = "ami-b144e6d1"
  }
}
#custom AMI defined from the original one, from an instance of the ami : ami-e26bec82
variable ranche-os-ami {
  type = "map"
  default = {
    ap-northeast-1 = "ami-637dfe03"
    ap-northeast-2 = "ami-637dfe03"
    ap-south-1 = "ami-637dfe03"
    ap-southeast-1 = "ami-637dfe03"
    ap-southeast-2 = "ami-637dfe03"
    eu-central-1 = "ami-637dfe03"
    eu-west-1 = "ami-637dfe03"
    eu-west-2 = "ami-637dfe03"
    sa-east-1 = "ami-637dfe03"
    us-east-1 = "ami-637dfe03"
    us-east-2 = "ami-637dfe03"
    us-west-1 = "ami-637dfe03"
    us-west-2 = "ami-637dfe03"
  }
}
