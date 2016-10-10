# travis-pyenv
Set up [`pyenv`](https://github.com/yyuu/pyenv) to use in [Travis CI](https://travis-ci.org).

The Travis CI build images currently contain a very old version of PyPy which breaks a bunch of Python modules. This repository contains a script that can be used to set up a newer version of PyPy in your Travis CI builds using [pyenv](https://github.com/yyuu/pyenv).

## Usage
1. Set the `$PYENV_VERSION` environment variable to the Python to install.
2. Tell Travis to cache the `$HOME/.pyenv_cache` directory.
3. Download and source the script in `before_install`.

There are a few install options that can be set via environment variables:
* `PYENV_VERSION`
    The pyenv to install [required]
* `PYENV_VERSION_PATTERN`
    Pattern to (f)grep against the output of `python --version` to validate that the correct Python was installed [default: none]
* `PYENV_ROOT`
    Directory in which to install pyenv [default: `~/.pyenv`]
* `PYENV_RELEASE`
    Release tag of pyenv to download [default: clone from master]
* `PYTHON_BUILD_CACHE_PATH`
    Directory in which to cache PyPy builds [default: `~/.pyenv_cache`]


### Example `travis.yml`
```yaml
language: python
matrix:
  include:
    - python: '2.7'
    - python: '3.5'
    - python: pypy
      env: PYENV_VERSION="pypy-5.4.1" PYENV_VERSION_PATTERN="PyPy 5\.4\.1"
cache:
  - pip
  - directories:
    - ~/.pyenv_cache

before_install:
  - |
      if [[ -n "$PYENV_VERSION" ]]; then
        git clone https://github.com/praekeltfoundation/travis-pyenv.git ~/travis-pyenv
        source ~/travis-pyenv/setup-pyenv.sh
      fi

script:
  - pytest my_project
```

## Notes
* Installing pyenv by downloading a release tag rather than cloning the git repo can make your builds a bit faster in some cases. Set the `PYENV_RELEASE` environment variable to achieve that.
* pyenv fails to install properly if ~/.pyenv is present, even if the directory is empty. So if you cache any directories within ~/.pyenv then you will probably break pyenv.
