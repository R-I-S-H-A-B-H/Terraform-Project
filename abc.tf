provider "aws" {
	region = "ap-south-1"
	profile = "rishabh"
}

resource "aws_instance" "Myinstance1" {
	ami             = "ami-0447a12f28fddb066"
	instance_type   = "t2.micro"
	key_name        = "mykey999"
	security_groups = ["MySG-rishabh"]
	
	tags = {
		Name = "RK"
	}

connection {
	type        = "ssh"
	user        = "ec2-user"
	private_key = file("C:/Users/rishabh kalyani/Downloads/mykey999.pem)
	host        = aws_instance.Myinstance1.public_ip
	}

provisioner "remote-exec" {
	inline = [ "sudo yum install httpd php git -y",
		   "sudo systemctl restart htttpd    ",
		   "sudo systemctl enable httpd      ",
		   "sudo git clone https://github.com/
}


