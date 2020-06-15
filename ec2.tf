provider "aws" {
	region = "ap-south-1"
	profile = "rishabh"
}

resource "tls_private_key" "mykey" {
	algorithm = "RSA"
}

output "mykey" {
	value = tls_private_key.mykey.public_key_openssh
}

output "mykey2" {
	value = tls_private_key.mykey.private_key_pem
}

resource "aws_key_pair" "mykey" {
	key_name   = "newkey"
	public_key = tls_private_key.mykey.public_key_openssh
}

resource "aws_security_group" "MySG" {
	depends_on  = [aws_key_pair.mykey,]

	name        = "MySG-rishabh"
	description = "Allow SSH on Port 22 and HTTP traffic on Port 80"
	vpc_id      = "vpc-f6f2ef9e"
	
	ingress {
		description = "ssh"
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "http"
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "mysg"
	}
}

resource "aws_instance" "Myinstance1" {
	depends_on      = [aws_security_group.MySG,]

	ami             = "ami-0447a12f28fddb066"
	instance_type   = "t2.micro"
	key_name        = aws_key_pair.mykey.key_name
	security_groups = [aws_security_group.MySG.name]

	connection {
		type        = "ssh"
		user        = "ec2-user"
		private_key = tls_private_key.mykey.private_key_pem
		host        = aws_instance.Myinstance1.public_ip
		}

	provisioner "remote-exec" {
		inline = [ 
			   "sudo yum install httpd php git -y",
			   "sudo systemctl start httpd",
			   "sudo systemctl enable httpd"
			 ]
		}

	tags = {
		Name = "RK-Terraform-OS"
	}
}

output "mypublicip" {
	value = aws_instance.Myinstance1.public_ip
}

resource "null_resource" "local1" {
	provisioner "local-exec" {
		command = "echo ${aws_instance.Myinstance1.public_ip} > publicip.txt"
		}
}

resource "null_resource" "local2" {
	depends_on = [null_resource.remote3,]

	provisioner "local-exec" {
		command = "chrome ${aws_instance.Myinstance1.public_ip}"
		}
}

resource "aws_ebs_volume" "EBS1" {
	depends_on        = [aws_instance.Myinstance1,]

	availability_zone = aws_instance.Myinstance1.availability_zone
	size              = 5

	tags = {
		Name = "MYEBS"
	}
}

resource "aws_volume_attachment" "EBS_ATTACH" {
	depends_on   = [aws_ebs_volume.EBS1,]

	device_name  = "/dev/sdh"
	volume_id    = "${aws_ebs_volume.EBS1.id}"
	instance_id  = "${aws_instance.Myinstance1.id}"
	force_detach = true
}

resource "null_resource" "remote3" {
	depends_on = [aws_volume_attachment.EBS_ATTACH,]	

	connection {
		type        = "ssh"
		user        = "ec2-user"
		private_key = tls_private_key.mykey.private_key_pem
		host        = aws_instance.Myinstance1.public_ip
	}
	
	provisioner "remote-exec" {
		inline = [
			  "sudo mkfs.ext4 /dev/xvdh",
			  "sudo mkdir /mydata",
			  "sudo mount /dev/xvdh /mydata",
			  "sudo mount /dev/xvdh /var/www/html",
			  "sudo rm -rf /var/www/html/*",
			  "sudo git clone https://github.com/R-I-S-H-A-B-H/Terraform-Project.git /var/www/html/"
			 ]
		}
}


















