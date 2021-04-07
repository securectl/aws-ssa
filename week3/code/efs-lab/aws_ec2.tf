module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "ec2-cluster"
  instance_count         = 2

  ami                    = "ami-0742b4e673072066f"
  instance_type          = "t2.small"
  key_name               = "ec2-key-nfs"
  monitoring             = true
  vpc_security_group_ids = ["sg-0eb5e6ef594414a22"]
  subnet_id              = "subnet-04d2729a7fea88f81"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}