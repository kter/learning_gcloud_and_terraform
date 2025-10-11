.PHONY: help init apply destroy

# Default target
help:
	@echo "Available targets:"
	@echo "  init              - Initialize all Terraform modules"
	@echo "  apply             - Apply all infrastructure (vpc -> db -> cloudrun -> loadbalancer)"
	@echo "  destroy           - Destroy all infrastructure (loadbalancer -> cloudrun -> db -> vpc)"

# Initialize all modules
init:
	@echo "Initializing IAM..."
	cd iam && terraform init
	@echo "Initializing VPC..."
	cd vpc && terraform init
	@echo "Initializing DB..."
	cd db && terraform init
	@echo "Initializing Cloud Run..."
	cd cloudrun && terraform init
	@echo "Initializing Load Balancer..."
	cd loadbalancer && terraform init

# Apply infrastructure in correct order: VPC -> Cloud Run -> Load Balancer
apply:
	@echo "Applying IAM infrastructure..."
	cd iam && terraform init -upgrade && terraform apply -auto-approve
	@echo "Applying VPC infrastructure..."
	cd vpc && terraform init -upgrade && terraform apply -auto-approve
	@echo "Applying DB infrastructure..."
	cd db && terraform init -upgrade && terraform apply -auto-approve
	@echo "Applying Cloud Run infrastructure..."
	cd cloudrun && terraform init -upgrade && terraform apply -auto-approve
	@echo "Applying Load Balancer infrastructure..."
	cd loadbalancer && terraform init -upgrade && terraform apply -auto-approve
	@echo "All infrastructure has been applied successfully!"

# Destroy infrastructure in reverse order: Load Balancer -> Cloud Run -> VPC
destroy:
	@echo "Destroying Load Balancer infrastructure..."
	cd loadbalancer && terraform destroy -auto-approve
	@echo "Destroying Cloud Run infrastructure..."
	cd cloudrun && terraform destroy -auto-approve
	@echo "Destroying DB infrastructure..."
	cd db && terraform destroy -auto-approve
	@echo "Destroying VPC infrastructure..."
	cd vpc && terraform destroy -auto-approve
	@echo "Destroying IAM infrastructure..."
	cd iam && terraform destroy -auto-approve
	@echo "All infrastructure has been destroyed successfully!"