packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

source "amazon-ebs" "amazonlinux" {
  ami_name                    = "packer-benchpark-{{timestamp}}"
  instance_type               = "m6a.xlarge"
  region                      = var.region
  subnet_id                   = "subnet-0577fc5586789e0a2"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"] # Amazon's official account
  }

  ssh_username = "ec2-user"
}

build {
  name    = "caliper-benchpark"
  sources = ["source.amazon-ebs.amazonlinux"]

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }

  provisioner "file" {
    source      = "jupyter.service"
    destination = "/home/ec2-user/jupyter.service"
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker git curl wget gcc gcc-c++ make pip vi",

      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      "cd /home/ec2-user && git clone https://github.com/LLNL/benchpark.git",
      "cd /home/ec2-user && sudo docker build -t jupyter .",

      "sudo mv /home/ec2-user/jupyter.service /etc/systemd/system/jupyter.service",
      "sudo systemctl enable jupyter.service",

      "cd /home/ec2-user",
      "wget https://github.com/Kitware/CMake/releases/download/v3.29.2/cmake-3.29.2-linux-x86_64.tar.gz",
      "tar -xzf cmake-3.29.2-linux-x86_64.tar.gz",
      "mv cmake-3.29.2-linux-x86_64 cmake-bin",
      "rm cmake-3.29.2-linux-x86_64.tar.gz",


      "echo 'export PATH=$HOME/cmake-bin/bin:$PATH' >> /home/ec2-user/.bashrc",
      "echo 'export PYTHONPATH=\"/opt/conda/lib/python3.9/site-packages:$PYTHONPATH\"' >> /home/ec2-user/.bashrc",


      "sudo chown -R ec2-user:ec2-user /home/ec2-user"
    ]
  }
}
