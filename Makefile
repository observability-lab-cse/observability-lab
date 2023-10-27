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

push:
	@echo "Build and push application"
	@bash ./sample-application/sample.sh --push

deploy_secret_store:
	@echo "Deploy secret store provider"
	@bash ./sample-application/sample.sh --deploy_secret_store

deploy:
	@echo "Deploy application to AKS"
	@bash ./sample-application/sample.sh --deploy

deploy-devices-simulator:
	@echo "Deploy Devices Simulator to AKS"
	@bash ./sample-application/sample.sh --deploy_devices_simulator