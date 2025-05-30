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
      name                = "amzn2-ami-hvm-2.0.20250512.0-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"] # Amazon's official account
  }

  ssh_username = "ec2-user"
}

build {
  name    = "benchpark"
  sources = ["source.amazon-ebs.amazonlinux"]
  
  # Copy the custom .bashrc file
  provisioner "file" {
    source      = ".bashrc"
    destination = "~/.bashrc"
  }
  
  provisioner "file" {
    source      = "Dockerfile"
    destination = "$HOME/Dockerfile"
  }
  
  provisioner "file" {
    source      = "jupyter.service"
    destination = "$HOME/jupyter.service"
  }
  
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker git curl wget gcc gcc-c++ make pip vi openmpi mpirun",
      
      #Starting Docker
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Benchpark
      "cd $HOME && git clone https://github.com/LLNL/benchpark.git",

      #Buiulding Jupyter Container
      "cd $HOME && sudo docker build -t jupyter .",

      # Starting Jupyter Service
      "sudo mv $HOME/jupyter.service /etc/systemd/system/jupyter.service",
      "sudo systemctl enable jupyter.service",

      # Installing cmake
      "cd $HOME",
      "wget https://github.com/Kitware/CMake/releases/download/v3.29.2/cmake-3.29.2-linux-x86_64.tar.gz",
      "tar -xzf cmake-3.29.2-linux-x86_64.tar.gz",
      "mv cmake-3.29.2-linux-x86_64 cmake-bin",
      "rm cmake-3.29.2-linux-x86_64.tar.gz",

      "wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz",
      "tar -xzf openmpi-4.1.6.tar.gz",
      "cd openmpi-4.1.6",
      "./configure --prefix=$HOME/openmpi --disable-fortran",
      "make -j$(nproc)",
      "make install",
      "export PATH=$HOME/openmpi/bin:$PATH",

      "sudo chown -R $USER:$USER $HOME"
    ]
  }
}
