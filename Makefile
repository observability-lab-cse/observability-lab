.PHONY: all deploy build
include .env
SHELL = /bin/bash


all: provision push deploy-otel-collector deploy

provision:
	@echo "Creating Infrastructure"
	@bash ./infrastructure/setup_infra.sh --create

delete:
	@echo "Delete Infrastructure"
	@bash ./infrastructure/setup_infra.sh --delete

push:
	@echo "Build and push application"
	@bash ./sample-application/sample.sh --push

deploy:
	@echo "Deploy application to AKS"
	@bash ./sample-application/sample.sh --deploy

deploy-otel-collector:
	@echo "Deploy Open Telemetry Collector to AKS"
	@bash ./sample-application/sample.sh --deploy_otel_collector

deploy-devices-simulator:
	@echo "Deploy Devices Simulator to AKS"
	@bash ./sample-application/sample.sh --deploy_devices_simulator