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

deploy-otel-operator-with-collector:
	@echo "Deploy Open Telemetry Collector to AKS"
	@bash ./sample-application/sample.sh --deploy_opentelemetry_operator_with_collector

deploy-devices-data-simulator:
	@echo "Deploy Devices Data Simulator to AKS"
	@bash ./sample-application/sample.sh --deploy_devices_data_simulator