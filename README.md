# AWS Grocery Project

## Project Overview

AWS Grocery is a cloud-based application deployed on AWS. 
It includes an EC2 instance, PostgreSQL RDS database, S3 bucket for storing avatars, and a secure network setup (VPC, subnets, security groups, internet gateway). 
Terraform is used for infrastructure provisioning and management.

---
## Architecture Diagram

![Infrastructure Architecture](infrastructure/infrastructure_architech.png)


*Diagram shows the VPC, subnets, IGW, EC2, RDS, and S3 bucket.*

---
## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with access credentials
- Git
- AWS account

---
## Terraform Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/peridianjoytabe1980-ai/AWS_grocery.git
   cd AWS_grocery/infrastructure

2. Initialize Terraform:

    terraform init

3. Review the Terraform plan:

    terraform plan

4. Apply the Terraform plan:

    terraform apply

Enter your RDS password when prompted. Must be >= 8. Only printable ASCII characters besides '/', '@', '"', ' ' may be used.


---

## List Terraform Outputs
Include a table of important outputs so users know what resources were created:

```markdown
Terraform Outputs

| Output | Example Value | Description |
|--------|---------------|-------------|
| `aws_region` | `eu-central-1` | AWS region where resources are deployed |
| `db_endpoint` | `terraform-xxxx.rds.amazonaws.com:5432` | RDS database endpoint |
| `db_instance_id` | `db-xxxxxxxx` | RDS instance ID |
| `ec2_instance_id` | `i-xxxxxxxx` | EC2 instance ID |
| `ec2_public_ip` | `35.156.167.241` | Public IP of the EC2 instance |
| `avatars_bucket_name` | `grocerymate-avatars-tabe2` | S3 bucket for avatars |

```
---
## Usage

- SSH into the EC2 instance:
  ```bash
  ssh -i <your-key.pem> ec2-user@<ec2_public_ip>

- Connect to PostgreSQL:

  psql -h <db_endpoint> -U <db_username> -d <db_name>

- Access S3 bucket via AWS CLI or console


---

## Notes and Best Practices
```markdown
## Notes

- Do **not** commit `.terraform/` or Terraform state files; they are local only.
- Store passwords securely using Terraform variables with `sensitive = true`.
```

## 🐳 Docker Containerization
Overview

The GroceryMate application is fully containerized using Docker to ensure portability, consistency across environments, and simplified deployment.

By packaging the application code, dependencies, and runtime into a container image, the app can run consistently across local development and AWS environments.

## Dockerfile Explanation

The application uses the official Python 3.9 base image:
FROM python:3.9

The working directory is set inside the container:
WORKDIR /app

Application files and environment configuration are copied:
COPY . .
COPY .env .env

Dependencies are installed:
RUN pip install --no-cache-dir -r requirements.txt

The application starts with:
CMD ["python", "run.py"]

## Build the Docker Image
docker build -t grocerymate-app .

## Run the Container Locally
docker run -d -p 5000:5000 grocerymate-app

Adjust the port if your app runs on a different one.
