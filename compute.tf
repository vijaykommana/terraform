resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = local.http_port
    to_port          = local.http_port
    protocol         = "tcp"
    cidr_blocks      = [local.anywhere]
    
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = local.ssh_port
    to_port          =local.ssh_port
    protocol         = "tcp"
    cidr_blocks      = [local.anywhere]
  
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "secure"
  }
}

data "aws_subnet" "web" {
  vpc_id = aws_vpc.main.id
  filter {
    name = "tag:Name"
    values = [var.vpc_info.web_subnet]
  }
}
resource "aws_instance" "web" {
  ami = "ami-0430580de6244e02e"
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.id
  instance_type = "t2.micro"
  subnet_id  = data.aws_subnet.web.id
  user_data  = file("apache.sh")
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
 

  tags = {
    Name = "web"
  }
  depends_on = [ aws_security_group.allow_tls ]




}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCIiksUg4lrNPSwbYyzJMvypR7fcBIke50N+L5VHbEZzRPAneYI/Hsl2aivA27beqQOXspnriii1uMF+9ZaN4vovueQz4Cf+mhvzsJFAyEU5RxtYuYYHXIEprqwTe/q1/gA/jiuv+xmk1hOBcKcnsi4a0xdD7hp9ny/LI4ImCW45Hde0pdeVwJr6b8codijXgTNM3d9gen0KVAs6SkAQiR6yu3cvC80XO9C4Ysa7ILvJAzGLoB89aHVbk0F8C7yA1hm/7x8w72BJA0QjSfsnwger3U+McVPkmWlETNOXOClkD2LTzL+tuxUSufOKDe3/SGJ412eKt0SWPqkPKx9s/7P6gzw41ipCk0vKHYJhLH+MHrIaxyUZBsJLmJgtVtOf3vrFN+jx9rQmEyo4Wtz75SSy1dcxmaYThThZrhZmjAVzTcUuVPO1x7mfHohpYcCY3h8jL07VXFlyC099wrRVCvrGj9+XKRUrWwVMhD4IKVrWdKEgDNnRgJe+gfZUOyD6k= 91966@vijay"
}
