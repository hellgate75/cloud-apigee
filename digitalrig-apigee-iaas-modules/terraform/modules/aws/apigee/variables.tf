variable default-nat-ami {
  type = "map"
  default = {
    us-east-1 = "ami-311a1a5b"
    us-east-2 = "ami-8d5a00e8"
    us-west-1 = "ami-0d087a6d"
    us-west-2 = "ami-7a2bc21a"
    eu-west-1 = "ami-d03288a3"
    eu-central-1 = "ami-42db3c2d"
    ap-northeast-1 = "ami-bb010ad5"
    ap-northeast-2 = "ami-0199506f"
    ap-southeast-1 = "ami-920cc7f1"
    ap-southeast-2 = "ami-162c0c75"
    sa-east-1 = "ami-22169b4e"
  }
}

variable default-windows-ami {
  type = "map"
  default = {
    us-east-1 = "ami-e53980f2"
    us-east-2 = "ami-3c792359"
    eu-west-1 = "ami-6ad1b419"
    us-west-2 = "ami-246cad44"
    eu-central-1 = "ami-d15593be"
  }
}
