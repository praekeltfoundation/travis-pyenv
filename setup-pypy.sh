# NOTE: This script needs to be sourced so it can modify the environment.
#
# Environment variables that can be set:
# - PYPY_VERSION
#     Version of PyPy2 to install [required]
# - PYENV_ROOT
#     Directory in which to install pyenv [default: ~/.pyenv]
# - PYENV_RELEASE
#     Release tag of pyenv to download [default: clone from master]
# - PYTHON_BUILD_CACHE_PATH:
#     Directory in which to cache PyPy builds [default: ~/.pyenv_cache]

if [[ -z "$PYPY_VERSION" ]]; then
  echo "\$PYPY_VERSION is not set. Not installing PyPy."
  return 0
fi

# Get out of the virtualenv we're in.
deactivate

# Install pyenv
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [[ -n "$PYENV_RELEASE" ]]; then
  # Fetch the release archive from Github (slightly faster than cloning)
  mkdir "$PYENV_ROOT"
  curl -SL "https://github.com/yyuu/pyenv/archive/$PYENV_RELEASE.tar.gz" | \
    tar -xz -C "$PYENV_ROOT" --strip-components 1 -
else
  # Don't have a release to fetch, so just clone directly
  git clone --depth 1 https://github.com/yyuu/pyenv.git "$PYENV_ROOT"
fi

export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Make sure the cache directory exists
PYTHON_BUILD_CACHE_PATH="${PYTHON_BUILD_CACHE_PATH:-$HOME/.pyenv_cache}"
mkdir -p "$PYTHON_BUILD_CACHE_PATH"

# Install pypy and make a virtualenv for it.
pyenv install -s pypy-$PYPY_VERSION
pyenv global pypy-$PYPY_VERSION
virtualenv -p $(which python) "$HOME/env-pypy-$PYPY_VERSION"
source "$HOME/env-pypy-$PYPY_VERSION/bin/activate"

if ! python --version 2>&1 | fgrep "PyPy $PYPY_VERSION"; then
  echo "Failed to verify that PyPy was properly installed."
  return 1
fi
