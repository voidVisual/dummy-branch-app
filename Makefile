.PHONY: help up down restart logs ps shell test clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start all services in detached mode (Development)
	docker-compose up -d --build

down: ## Stop all services and remove containers
	docker-compose down

restart: ## Restart all services
	docker-compose down && docker-compose up -d --build

logs: ## View logs for all services (follow mode)
	docker-compose logs -f

ps: ## List running containers
	docker-compose ps

shell: ## Open a shell inside the API container
	docker-compose exec api /bin/bash

db-shell: ## Open a psql shell inside the DB container
	docker-compose exec db psql -U postgres -d microloans

test: ## Run tests (placeholder)
	docker-compose exec api pytest

clean: ## Remove all containers, networks, and volumes
	docker-compose down -v
	find . -type d -name "__pycache__" -exec rm -rf {} +
