# NOTE: This script needs to be sourced so it can modify the environment.
#
# Environment variables that can be set:
# - PYENV_VERSION
#     Python to install [required]
# - PYENV_VERSION_PATTERN
#     Pattern to (f)grep against the output of `python --version` to validate
#     that the correct Python was installed [default: none]
# - PYENV_ROOT
#     Directory in which to install pyenv [default: ~/.pyenv]
# - PYENV_RELEASE
#     Release tag of pyenv to download [default: clone from master]
# - PYTHON_BUILD_CACHE_PATH:
#     Directory in which to cache PyPy builds [default: ~/.pyenv_cache]

if [[ -z "$PYENV_VERSION" ]]; then
  echo "\$PYENV_VERSION is not set. Not installing a pyenv."
  return 0
fi

# Get out of the virtualenv we're in.
deactivate

# Install pyenv
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [[ -n "$PYENV_RELEASE" ]]; then
  # Fetch the release archive from Github (slightly faster than cloning)
  mkdir "$PYENV_ROOT"
  curl -fSL "https://github.com/yyuu/pyenv/archive/$PYENV_RELEASE.tar.gz" | \
    tar -xz -C "$PYENV_ROOT" --strip-components 1
else
  # Don't have a release to fetch, so just clone directly
  git clone --depth 1 https://github.com/yyuu/pyenv.git "$PYENV_ROOT"
fi

export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Make sure the cache directory exists
PYTHON_BUILD_CACHE_PATH="${PYTHON_BUILD_CACHE_PATH:-$HOME/.pyenv_cache}"
mkdir -p "$PYTHON_BUILD_CACHE_PATH"

# Install the pyenv
pyenv install "$PYENV_VERSION"
pyenv global "$PYENV_VERSION"

# Make and source a new virtualenv
VIRTUAL_ENV="$HOME/ve-pyenv-$PYENV_PYTHON"
virtualenv -p "$(which python)" "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

if [[ -n "$PYENV_VERSION_PATTERN" ]]; then
  if ! python --version 2>&1 | fgrep "$PYENV_VERSION_PATTERN"; then
    echo "Failed to verify that the pyenv was properly installed."
    return 1
  fi
fi
