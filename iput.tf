variable "region" {
  type = string
  default = "us-east-2"
}
variable "vpc_info" {
  type = object({
      subnet_names = list(string),
      az = list(string)
      vpc_cidr = string
      public_subnets = list(string)
      private_subnets = list(string)
      web_subnet = string
  })
  default = {
    subnet_names = ["app1","app2","db1","db2","web1","web2"] ,
    az = ["a","b","c","a","b","c"]
    vpc_cidr =  "192.168.0.0/16" 
    public_subnets = ["app1","app2","db1","db2"]
    private_subnets = [ "web1","web2" ]
    web_subnet = "app1"
  }
}