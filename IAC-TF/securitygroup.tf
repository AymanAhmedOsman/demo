
#------------------------- secutity group ssh only -----------------------------
resource "aws_security_group" "allow_ssh-http" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and "
  vpc_id      = aws_vpc.Demo.id

  tags = {

    Name = "ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh-http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh-http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_ssh-http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}





#------------------------------ sg-database ------------------

resource "aws_security_group" "sg-mysql" {
  name ="allow ec2 access db"
  description = "allow ec2 access db through tcp-udp port"
  vpc_id = aws_vpc.Demo.id
    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_2.cidr_block]
  }

  tags = {
    name ="tcp-udp"
  }
  
}

