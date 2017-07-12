#!/usr/bin/env bash
# DEPRECATED: Please use setup-pyenv.sh rather.
# NOTE: This script needs to be sourced so it can modify the environment.
#
# Environment variables that can be set:
# - PYPY_VERSION
#     Version of PyPy2 to install [required]
# - PYENV_ROOT
#     Directory in which to install pyenv [default: ~/.travis-pyenv]
# - PYENV_RELEASE
#     Release tag of pyenv to download [default: clone from master]
# - PYTHON_BUILD_CACHE_PATH:
#     Directory in which to cache PyPy builds [default: ~/.pyenv_cache]

echo 'WARNING: setup-pypy.sh is *deprecated*. Please use setup-pyenv.sh rather.'
echo 'setup-pypy.sh will be removed in the next release.'

if [[ -z "$PYPY_VERSION" ]]; then
  echo "\$PYPY_VERSION is not set. Not installing PyPy."
  return 0
fi

export PYENV_VERSION="pypy-$PYPY_VERSION"
export PYENV_VERSION_STRING="PyPy $PYPY_VERSION"

# shellcheck source=setup-pyenv.sh
source "$(dirname "${BASH_SOURCE[0]}")"/setup-pyenv.sh
