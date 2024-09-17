#!/bin/bash
set -eu

# Create Python virtual environment
cd sample-application/device-assistant/
poetry install

# Azure CLI download the Bicep binary in the wrong architecture on linux/arm64.
# See Azure/azure-cli#29435
if [ "$(arch)" == "aarch64" ];then
  az bicep uninstall
  az bicep install --target-platform linux-arm64
fi