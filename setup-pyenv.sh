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

# Function: verify_python -- attempts to call the Python command supplied in
# the first argument with the --version flag. If PYENV_VERSION_STRING is set,
# then it validates the returned version string as well (via fgrep). Returns
# whatever status code the command returns.
verify_python() {
  local python_bin="$1"

  if [[ -n "$PYENV_VERSION_STRING" ]]; then
    "$python_bin" --version 2>&1 | fgrep "$PYENV_VERSION_STRING" &>/dev/null
  else
    "$python_bin" --version &>/dev/null
  fi
}

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

# Verify the PYENV_VERSION in the cache; if it doesn't verify, use pyenv to
# download and build from scratch, then move to cache if the build succeeds
version_cache_path="$PYENV_CACHE_PATH/$PYENV_VERSION"
version_pyenv_path="$PYENV_ROOT/versions/$PYENV_VERSION"
if ! verify_python "$version_cache_path/bin/python"; then
  echo "Valid $PYENV_VERSION not found in cache, installing from scratch"

  if pyenv install "$PYENV_VERSION"; then
    if verify_python "$version_pyenv_path/bin/python"; then
      # Remove an existing (broken) build from the cache if one exists
      if [[ -d "$version_cache_path" ]]; then
        rm -rf "$version_cache_path"
      fi
      mv "$version_pyenv_path" "$PYENV_CACHE_PATH"
    else
      echo "Failed to verify that the pyenv was properly installed."
      return 1
    fi
  else
    echo "pyenv build failed."
    return 1
  fi
fi

# Create a link in $PYENV_ROOT/versions to the cached version build
ln -s "$version_cache_path" "$version_pyenv_path"
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

if ! verify_python "python"; then
  echo "Failed to verify that the pyenv was properly installed."
  return 1
fi
