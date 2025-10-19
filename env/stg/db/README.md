# Database Module

This directory contains the Terraform configuration for the Cloud SQL database infrastructure in the STG environment.

## Resources

- Cloud SQL PostgreSQL instance
- Private IP configuration
- Database users and permissions
- Bastion host for database access

## Usage

Initialize and apply:
```bash
terraform init
terraform apply
```

## Outputs

- `instance_connection_name`: Connection name for Cloud SQL proxy
- `private_ip_address`: Private IP address of the database
- `bastion_internal_ip`: Internal IP of the bastion host
- `bastion_ssh_command`: Command to SSH into the bastion
- `postgres_password`: PostgreSQL admin password (sensitive)
