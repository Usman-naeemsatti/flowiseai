#EC2-Flowise

resource "aws_instance" "flowise" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.kp.key_name
  subnet_id                   = aws_subnet.public1.id
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data = templatefile("user-data.sh", {
    
    PORT                = var.flow_port,
    DATABASE_TYPE       = var.db_type,
    DATABASE_PORT       = var.db_port,
    DATABASE_HOST       = aws_db_instance.flowise.endpoint,
    DATABASE_NAME       = var.db_name,
    DATABASE_USER       = var.db_user,
    DATABASE_PASSWORD   = var.db_pass,  
  })
  
  depends_on = [
    aws_db_instance.flowise
  ]
  
  tags = {
    Name = "Flowise_Instance"
  }
}

#EC2-Langfuse

resource "aws_instance" "langfuse" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.kp.key_name
  subnet_id                   = aws_subnet.public1.id
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data = templatefile("langfuse-data.sh", {

  PORT       =  var.flow_port,
  db_host    =  aws_db_instance.flowise.endpoint,
  db_name    =  var.db_name,
  db_user    =  var.db_user,
  db_pass    =  var.db_pass,
  })

  depends_on = [
    aws_db_instance.flowise
  ]

  tags = {
    Name = "Langfuse_Instance"
  }
}

resource "aws_db_instance" "flowise" {
  allocated_storage    = var.db_storage
  storage_type         = var.db_storage_type
  instance_class       = var.db_storage_class
  identifier           = var.db_identifier
  engine               = var.db_engine
  engine_version       = var.db_engine_version

  db_name  = var.db_name
  username = var.db_user
  password = var.db_pass

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  skip_final_snapshot    = true

  tags = {
    Name = "RDS Instance"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# RDS security group
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }


  tags = {
    Name = "RDS Security Group"
  }
}

#keypair

resource "tls_private_key" "pk" {
  algorithm = "RSA"
}

resource "aws_key_pair" "kp" {
  key_name   = "mykey2" # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.pk.private_key_pem}' > ./mykey2.pem
      chmod 400 ./mykey2.pem
    EOT
  }
}
