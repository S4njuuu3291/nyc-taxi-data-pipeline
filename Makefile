.PHONY: docker-up docker-down docker-build docker-restart

docker-up:
	docker compose -f docker-compose.dev.yaml up -d

docker-down:
	docker compose -f docker-compose.dev.yaml down

docker-build:
	docker compose -f docker-compose.dev.yaml build

docker-restart:
	docker compose -f docker-compose.dev.yaml restart