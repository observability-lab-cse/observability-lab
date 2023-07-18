.PHONY: all deploy build
include .env
SHELL = /bin/bash


all: provision push deploy

provision:
	@echo "Creating Infrastructure"
	@bash ./infrastructure/setup_infra.sh --create

delete:
	@echo "Delete Infrastructure"
	@bash ./infrastructure/setup_infra.sh --delete

push:
	@echo "Build and push application"
	@bash ./sample-application/sample.sh --push

run:
	@echo "Run application localy"
	@bash ./sample-application/sample.sh --run

deploy:
	@echo "Deploy application to AKS"
	@bash ./sample-application/sample.sh --deploy

deploy-devices-simulator:
	@echo "Deploy Devices Simulator to AKS"
	@bash ./sample-application/sample.sh --deploy_devices_simulator