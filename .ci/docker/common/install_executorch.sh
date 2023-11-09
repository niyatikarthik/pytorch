#!/bin/bash

set -ex

source "$(dirname "${BASH_SOURCE[0]}")/common_utils.sh"

clone_executorch() {
  EXECUTORCH_PINNED_COMMIT=$(get_pinned_commit executorch)

  # Clone the Executorch
  git clone https://github.com/pytorch/executorch.git
  chown -R jenkins executorch

  # and fetch the target commit
  pushd executorch
  git checkout "${EXECUTORCH_PINNED_COMMIT}"
  pod
}

install_buck2() {
  pushd executorch/.ci/docker

  BUCK2_VERSION=$(cat ci_commit_pins/buck2.txt)
  source common/install_buck.sh

  popd
}

install_conda_dependencies() {
  pushd executorch/.ci/docker
  # Install conda dependencies like flatbuffer
  conda_install --file conda-env-ci.txt
  popd
}

install_pip_dependencies() {
  pushd executorch/.ci/docker

  # Install all Python dependencies
  pip_install -r requirements-ci.txt

  # NB: This might be switched to pinned commits later
  NIGHTLY=$(cat ci_commit_pins/nightly.txt)
  TORCHAUDIO_VERSION=$(cat ci_commit_pins/audio.txt)
  TORCHVISION_VERSION=$(cat ci_commit_pins/vision.txt)

  pip_install --pre \
    torchaudio=="${TORCHAUDIO_VERSION}" \
    torchvision=="${TORCHVISION_VERSION}" \
    --index-url https://download.pytorch.org/whl/nightly/cpu

  popd
}

setup_executorch() {
  pushd executorch
  source .ci/scripts/utils.sh

  install_flatc_from_source
  pip_install .
  as_jenkins build_executorch_runner "buck2"

  popd
}

clone_executorch
install_buck2
install_conda_dependencies
install_pip_dependencies
setup_executorch
