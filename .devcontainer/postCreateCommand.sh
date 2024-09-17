#!/bin/bash
set -eu

setup_permissions() {
  # Volume ownership is not set automatically due to a bug:
  # https://github.com/microsoft/vscode-remote-release/issues/9931
  #
  # Note volume ownership appears to get set all the way up the directory tree,
  # so if the volume is in sub/folder be sure to change ownership of both sub/ and
  # sub/folder.
  echo "*** Setting permissions"
  sudo chown $USER:$USER \
    /home/$USER/.azure \
    ./frontend/node_modules ./frontend \
    ./.venv

  # Mark workspace as safe: https://www.kenmuse.com/blog/avoiding-dubious-ownership-in-dev-containers/
  git config --global --add safe.directory "$(pwd)"
}

fix_bicep_arm64() {
  # Azure CLI download the Bicep binary in the wrong architecture on linux/arm64.
  # See Azure/azure-cli#29435
  if [ "$(arch)" == "aarch64" ];then
    echo "*** Installing Bicep"
    az bicep uninstall
    az bicep install --target-platform linux-arm64
  fi
}

setup_python_venv() {
  echo "*** Setting up Python virtual environment"
  pushd "sample-application/device-assistant" > /dev/null
    # Create the virtual environment in the source tree so VS Code can discover it
    poetry config virtualenvs.in-project true

    # Create a the virtualenv
    poetry install
  popd > /dev/null
}

# Main sequence
setup_permissions
fix_bicep_arm64
setup_python_venv