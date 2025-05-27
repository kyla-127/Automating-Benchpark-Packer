# Automating Benchpark with Packer

This project automates the creation of an Amazon Machine Image (AMI) that includes everything needed to run [Benchpark](https://github.com/LLNL/benchpark) inside a Jupyter Notebook environment. It uses **Packer** to provision an Amazon Linux EC2 instance, installs Docker, builds a custom Docker image with Benchpark pre-configured, and sets up a systemd service to run Jupyter automatically on boot.

## Prerequisites
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Packer](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-build-image)
- AWS credentials configured via `aws configure` or environment variables

## Build the AMI

### Step 1: Configure AWS credentials
1. Copy and Paste your unique AWS Credentials into the terminal

### Step 2: Build the AMI With Packer
1. Run the following command from the directory containing your benchpark.pkr.hcl and Dockerfile
    ```
    packer build benchpark.pkr.hcl
    ```

    If your build is successful you will have output that looks something like
        
        
        ==> Builds finished. The artifacts of successful builds are:
        --> caliper-benchpark.amazon-ebs.amazonlinux: AMIs were created:
        us-east-1: ami-0995bf89a8c655414
    
