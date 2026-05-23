.PHONY: docker-up docker-down docker-build docker-restart terraform-init-dev terraform-plan-dev terraform-apply-dev terraform-destroy-dev terraform-init-prod terraform-plan-prod terraform-apply-prod terraform-destroy-prod upload-glue-scripts

docker-up:
	docker compose -f docker-compose.dev.yaml up -d

docker-down:
	docker compose -f docker-compose.dev.yaml down

docker-build:
	docker compose -f docker-compose.dev.yaml build

docker-restart:
	docker compose -f docker-compose.dev.yaml restart

terraform-init-dev:
	terraform -chdir=terraform/environment/dev init

terraform-plan-dev:
	terraform -chdir=terraform/environment/dev plan

terraform-apply-dev:
	terraform -chdir=terraform/environment/dev apply -auto-approve

terraform-destroy-dev:
	terraform -chdir=terraform/environment/dev destroy -auto-approve

terraform-init-prod:
	terraform -chdir=terraform/environment/prod init

terraform-plan-prod:
	terraform -chdir=terraform/environment/prod plan

terraform-apply-prod:
	terraform -chdir=terraform/environment/prod apply -auto-approve

terraform-destroy-prod:
	terraform -chdir=terraform/environment/prod destroy -auto-approve

upload-glue-scripts:
	python3 scripts/upload_glue_scripts.py
