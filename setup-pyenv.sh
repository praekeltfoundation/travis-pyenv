# NOTE: This script needs to be sourced so it can modify the environment.
#
# Environment variables that can be set:
# - PYENV_VERSION
#     Python to install [required]
# - PYENV_VERSION_STRING
#     String to `fgrep` against the output of `python --version` to validate
#     that the correct Python was installed (recommended) [default: none]
# - PYENV_ROOT
#     Directory in which to install pyenv [default: ~/.pyenv]
# - PYENV_RELEASE
#     Release tag of pyenv to download [default: clone from master]
# - PYENV_CACHE_PATH
#     Directory where full Python builds are cached (i.e., for Travis)

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
  curl -fsSL "https://github.com/yyuu/pyenv/archive/$PYENV_RELEASE.tar.gz" \
    | tar -xz -C "$PYENV_ROOT" --strip-components 1
else
  # Don't have a release to fetch, so just clone directly
  git clone --depth 1 https://github.com/yyuu/pyenv.git "$PYENV_ROOT"
fi

export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Make sure the cache directory exists
PYENV_CACHE_PATH="${PYENV_CACHE_PATH:-$HOME/.pyenv_cache}"
mkdir -p "$PYENV_CACHE_PATH"


VERSION_CACHE_PATH="$PYENV_CACHE_PATH/$PYENV_VERSION"
VERSION_PYENV_PATH="$PYENV_ROOT/versions/$PYENV_VERSION"
# Check to see if this PYENV_VERSION is in the cache
if [[ ! -d "$VERSION_CACHE_PATH" ]]; then
  # If not, use pyenv to download and build from scratch, then move to cache
  echo "$PYENV_VERSION not found in cache"
  pyenv install "$PYENV_VERSION"
  mv "$VERSION_PYENV_PATH" "$PYENV_CACHE_PATH"
fi
# Create a link in .pyenv/versions to the cached version build
ln -s "$VERSION_CACHE_PATH" "$VERSION_PYENV_PATH"
# Reinitialize pyenv--if we skipped `pyenv install` and are using a previously
# cached version, then we need the shims etc. to be created so the pyenv will
# activate correctly.
eval "$(pyenv init -)"
pyenv global "$PYENV_VERSION"


# Make sure virtualenv is installed and up-to-date...
pip install -U virtualenv

# Then make and source a new virtualenv
VIRTUAL_ENV="$HOME/ve-pyenv-$PYENV_VERSION"
virtualenv -p "$(which python)" "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

if [[ -n "$PYENV_VERSION_STRING" ]]; then
  if ! python --version 2>&1 | fgrep "$PYENV_VERSION_STRING"; then
    echo "Failed to verify that the pyenv was properly installed."
    return 1
  fi
fi
