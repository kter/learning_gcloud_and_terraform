.PHONY: help init apply destroy destroy-check destroy-force plan

# Default target
help:
	@echo "Available targets:"
	@echo "  init              - Initialize all Terraform modules"
	@echo "  apply             - Apply all infrastructure (iam -> vpc -> db -> cloudrun -> loadbalancer)"
	@echo "  plan              - Show execution plan for all modules"
	@echo "  destroy-check     - Check for resources that may block destruction"
	@echo "  destroy           - Destroy all infrastructure (loadbalancer -> cloudrun -> db -> vpc -> iam)"
	@echo "  destroy-force     - Force destroy (skip confirmation prompts)"
	@echo ""
	@echo "⚠️  Before running destroy, please read: DESTROY_GUIDE.md"

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

# Plan infrastructure changes
plan:
	@echo "Planning IAM changes..."
	cd iam && terraform plan
	@echo "Planning VPC changes..."
	cd vpc && terraform plan
	@echo "Planning DB changes..."
	cd db && terraform plan
	@echo "Planning Cloud Run changes..."
	cd cloudrun && terraform plan
	@echo "Planning Load Balancer changes..."
	cd loadbalancer && terraform plan

# Check for resources that may block destruction
destroy-check:
	@echo "Checking for potential blockers..."
	@echo ""
	@echo "=== Cloud Run Services ==="
	@gcloud run services list --region=asia-northeast1 || true
	@echo ""
	@echo "=== Cloud Run Jobs ==="
	@gcloud run jobs list --region=asia-northeast1 || true
	@echo ""
	@echo "=== Serverless IP Addresses ==="
	@gcloud compute addresses list --regions=asia-northeast1 --filter="purpose=SERVERLESS" || true
	@echo ""
	@echo "=== VPC Peering Connections ==="
	@gcloud compute networks peerings list --network=vpc-network 2>/dev/null || echo "VPC network not found or no peerings"
	@echo ""
	@echo "=== Cloud SQL Instances ==="
	@gcloud sql instances list || true
	@echo ""
	@echo "⚠️  If any serverless IP addresses are listed, they may need 15-30 minutes to clean up after Cloud Run deletion."
	@echo "📖 For more details, see: DESTROY_GUIDE.md"

# Destroy infrastructure in reverse order: Load Balancer -> Cloud Run -> DB -> VPC -> IAM
# Note: This may fail if serverless IP addresses are still being cleaned up
destroy:
	@echo "⚠️  WARNING: This will destroy all infrastructure!"
	@echo "⚠️  Please ensure you have read DESTROY_GUIDE.md"
	@echo ""
	@echo "Press Ctrl+C to cancel, or wait 10 seconds to continue..."
	@sleep 10
	@echo ""
	@echo "Destroying Load Balancer infrastructure..."
	cd loadbalancer && terraform destroy -auto-approve || { echo "❌ Load Balancer destruction failed"; exit 1; }
	@echo "✅ Load Balancer destroyed"
	@echo ""
	@echo "Destroying Cloud Run infrastructure..."
	@echo "⚠️  Note: Serverless IP addresses will be automatically cleaned up in 15-30 minutes"
	cd cloudrun && terraform destroy -auto-approve || { echo "❌ Cloud Run destruction failed"; exit 1; }
	@echo "✅ Cloud Run destroyed"
	@echo ""
	@echo "Destroying DB infrastructure..."
	cd db && terraform destroy -auto-approve || { echo "⚠️  DB destruction failed - this is expected if Service Networking Connection is in use"; echo "Attempting to continue..."; }
	@echo ""
	@echo "Checking for Service Networking Connection cleanup..."
	@sleep 5
	@if gcloud compute networks peerings list --network=vpc-network 2>/dev/null | grep -q "servicenetworking"; then \
		echo "⚠️  VPC Peering still exists, attempting manual cleanup..."; \
		gcloud compute networks peerings delete servicenetworking-googleapis-com --network=vpc-network --quiet || true; \
		sleep 5; \
	fi
	@echo "Retrying DB infrastructure destruction..."
	cd db && terraform destroy -auto-approve || { echo "❌ DB destruction failed"; exit 1; }
	@echo "✅ DB destroyed"
	@echo ""
	@echo "Destroying VPC infrastructure..."
	cd vpc && terraform destroy -auto-approve || { \
		echo "❌ VPC destruction failed"; \
		echo ""; \
		echo "This is likely due to serverless IP addresses still being cleaned up."; \
		echo "Options:"; \
		echo "  1. Wait 15-30 minutes and run: cd vpc && terraform destroy -auto-approve"; \
		echo "  2. Run: ./cleanup_stuck_resources.sh"; \
		echo "  3. Check status: make destroy-check"; \
		echo ""; \
		echo "See DESTROY_GUIDE.md for more details."; \
		exit 1; \
	}
	@echo "✅ VPC destroyed"
	@echo ""
	@echo "Destroying IAM infrastructure..."
	cd iam && terraform destroy -auto-approve || { echo "❌ IAM destruction failed"; exit 1; }
	@echo "✅ IAM destroyed"
	@echo ""
	@echo "🎉 All infrastructure has been destroyed successfully!"

# Force destroy without confirmation (use with caution)
destroy-force:
	@echo "Destroying Load Balancer infrastructure..."
	cd loadbalancer && terraform destroy -auto-approve
	@echo "Destroying Cloud Run infrastructure..."
	cd cloudrun && terraform destroy -auto-approve
	@echo "Destroying DB infrastructure..."
	cd db && terraform destroy -auto-approve || true
	@sleep 5
	@gcloud compute networks peerings delete servicenetworking-googleapis-com --network=vpc-network --quiet 2>/dev/null || true
	cd db && terraform destroy -auto-approve || true
	@echo "Destroying VPC infrastructure..."
	cd vpc && terraform destroy -auto-approve || true
	@echo "Destroying IAM infrastructure..."
	cd iam && terraform destroy -auto-approve
	@echo "Destruction process completed (some resources may still be cleaning up)"