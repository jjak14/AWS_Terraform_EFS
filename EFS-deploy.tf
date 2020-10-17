provider "aws" {
  access_key = "your_accesskey_here"
  secret_key = "your_secretkey_here"
  region     = "us-east-1"
}


# Launch instance in public subnet with public security group 
resource "aws_instance" "EC2_01" {
  ami                 = "ami-0c94855ba95c71c99"
  instance_type       = "t2.micro"
  key_name            = "your_keypairname_here"
  availability_zone   = "us-east-1a"

  security_groups     = ["WebDMZ"]

  #user_data = file("mountefs.sh") (If you want to use a script from a separate file)

  user_data = <<-EOT
    #! /bin/bash
    sudo yum update -y
    sudo yum install amazon-efs-utils -y
    sudo yum install nfs-common -y
    sudo yum install nfs-utils -y
    sudo mkdir /home/ec2-user/efs
  EOT

  depends_on          = [aws_efs_mount_target.My_efs_mt1]

  tags = {
      Name = "EC2_Instance_01"
  }
}

resource "aws_instance" "EC2_02" {
  ami                 = "ami-0c94855ba95c71c99"
  instance_type       = "t2.micro"
  key_name            = "your_keypairname_here"
  availability_zone   = "us-east-1b"

  security_groups     = ["WebDMZ"]

  #user_data           = file("mountefs.sh")

  user_data = <<-EOT
    #! /bin/bash
    sudo yum update -y
    sudo yum install amazon-efs-utils -y
    sudo yum install nfs-common -y
    sudo yum install nfs-utils -y
    sudo mkdir /home/ec2-user/efs
  EOT

  depends_on          = [aws_efs_mount_target.My_efs_mt2]

  tags = {
      Name = "EC2_Instance_02"
  }
}


#Create an efs resource
resource "aws_efs_file_system" "My_efs" {
  creation_token      = "My_efs"
  encrypted           = true

  lifecycle_policy {
    transition_to_ia  = "AFTER_30_DAYS"
  }

  tags = {
    Name = "My_efs"
  }
}

#efs mount target
resource "aws_efs_mount_target" "My_efs_mt1" {
  file_system_id    = aws_efs_file_system.My_efs.id
  subnet_id         = "subnet-0660efef704efe191"
  security_groups   = ["sg-0f7e77e9d079013e8"]
}

resource "aws_efs_mount_target" "My_efs_mt2" {
  file_system_id    = aws_efs_file_system.My_efs.id
  subnet_id         = "subnet-0d2ff47a94316561f"
  security_groups   = ["sg-0f7e77e9d079013e8"]
}


#====== output handling ======
#Output EC2 instances public IPv4
output "EC2_01_PublicIPv4" {
  value = aws_instance.EC2_01.public_ip
}
output "EC2_02_PublicIPv4" {
  value = aws_instance.EC2_02.public_ip
}

#Output Mount Target IPv4 
output "MountTarget_01_IP_Add" {
  value = aws_efs_mount_target.My_efs_mt1.ip_address
}
output "MountTarget_02_IP_Add" {
  value = aws_efs_mount_target.My_efs_mt2.ip_address
}