.PHONY: all
include .env
SHELL = /bin/bash


all: provision

provision:
	@echo "Creating Infrastructure"
	@bash ./infrastructure/setup_infra.sh --create

provision-obs:
	@echo "Creating Observability Infrastructure"
	@bash ./infrastructure/setup_infra.sh --create-obs

delete:
	@echo "Delete Infrastructure"
	@bash ./infrastructure/setup_infra.sh --delete
