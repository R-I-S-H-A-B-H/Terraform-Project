resource "null_resource" "git" {
	provisioner "local-exec" {
		command = "git clone https://github.com/R-I-S-H-A-B-H/Terraform-Project.git"
	}
	provisioner "local-exec" {
		command = "cd .."
	}

}