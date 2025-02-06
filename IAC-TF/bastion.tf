



resource "aws_iam_role" "ssm_role" {
  name = "SSMRoleForBastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "SSMPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.ssm_role.name]
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfileForBastion"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "bastion" {
  ami                    = "ami-04b4f1a9cf54c11d0"  # Replace with your new AMI ID
  instance_type         = "t2.micro"
  subnet_id             = aws_subnet.public_1.id
  security_groups       = [aws_security_group.allow_ssh-http.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  key_name = "Demo"  # Replace with your key pair name

  user_data = <<-EOF
              #!/bin/bash
              echo Installing Docker...
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              usermod -aG docker $USER
              service docker start
              docker --version

              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin/kubectl
              EOF

  tags = {
    Name = "BastionHost"
  }
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
