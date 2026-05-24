terraform-init-dev:
	terraform -chdir=infrastructure/environments/dev init

terraform-validate-dev:
	terraform -chdir=infrastructure/environments/dev validate

terraform-plan-dev:
	terraform -chdir=infrastructure/environments/dev plan

terraform-apply-dev:
	terraform -chdir=infrastructure/environments/dev apply --auto-approve