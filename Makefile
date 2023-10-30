.PHONY: all deploy build
include .env
SHELL = /bin/bash


all: provision

provision:
	@echo "Creating Infrastructure"
	@bash ./infrastructure/setup_infra.sh --create

delete:
	@echo "Delete Infrastructure"
	@bash ./infrastructure/setup_infra.sh --delete
