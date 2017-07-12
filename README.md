# travis-pyenv

[![GitHub release](https://img.shields.io/github/release/praekeltfoundation/travis-pyenv.svg?style=flat-square)](https://github.com/praekeltfoundation/travis-pyenv/releases/latest)
[![Build status](https://img.shields.io/travis/praekeltfoundation/travis-pyenv/develop.svg?style=flat-square)](https://travis-ci.org/praekeltfoundation/travis-pyenv)

Set up [pyenv](https://github.com/yyuu/pyenv) to use in [Travis CI](https://travis-ci.org) builds.

Setting up pyenv properly in a Travis CI build environment can be quite tricky. This repo contains a script ([`setup-pyenv.sh`](setup-pyenv.sh)) that makes this process much simpler.

Use cases for this include:

* Install an up-to-date version of [PyPy](http://pypy.org). The Travis CI build images currently contain a very old version of PyPy which breaks some common Python modules.
* Install an exact version of [CPython](http://www.python.org) or some other lesser-known distribution that Travis CI doesn't support.
* Install Python on macOS builds.

## Usage
1. Set the `$PYENV_VERSION` environment variable to the Python to install.
2. Tell Travis to cache the `$HOME/.pyenv_cache` directory.
3. Download and source the `setup-pyenv.sh` script in `before_install`.
4. Build your project and run your tests as usual.

There are a few install options that can be set via environment variables:
* `PYENV_VERSION`
    The pyenv to install [required]
* `PYENV_VERSION_STRING`
    String to `grep -F` against the output of `python --version` to validate that the correct Python was installed (recommended) [default: none]
* `PYENV_ROOT`
    Directory in which to install pyenv [default: `~/.pyenv`]
* `PYENV_RELEASE`
    Release tag of pyenv to download [default: clone from master]
* `PYENV_CACHE_PATH`
    Directory in which to cache pyenv's Python builds [default: `~/.pyenv_cache`]


### Example `travis.yml`
```yaml
language: python
matrix:
  include:
    - env: PYENV_VERSION='2.7.13' PYENV_VERSION_STRING='Python 2.7.13'
    - python: '3.5'
    - env: PYENV_VERSION=pypy2.7-5.8.0 PYENV_VERSION_STRING='PyPy 5.8.0' PYENV_ROOT=$HOME/.travis-pyenv
      dist: trusty
cache:
  - pip
  - directories:
    - $HOME/.pyenv_cache

before_install:
  - |
      if [[ -n "$PYENV_VERSION" ]]; then
        wget https://github.com/praekeltfoundation/travis-pyenv/releases/download/0.3.0/setup-pyenv.sh
        source setup-pyenv.sh
      fi

script:
  - py.test my_project
```

## Notes
* Some recent PyPy versions and all recent ["Portable PyPy"](https://github.com/squeaky-pl/portable-pypy) versions **require Travis' [Trusty CI build environment](https://docs.travis-ci.com/user/trusty-ci-environment/)**. See [pyenv/pyenv#925](https://github.com/pyenv/pyenv/issues/925).
* Installing pyenv by downloading a release tag rather than cloning the git repo can make your builds a bit faster in some cases. Set the `PYENV_RELEASE` environment variable to achieve that.
* If you want to use `$PYENV_CACHE_PATH`, you must also set up Travis to cache this directory in your Travis configuration. Using the cache is optional, but it can greatly speed up subsequent builds.
* pyenv fails to install properly if the `$PYENV_ROOT` is already present, even if the directory is empty. So if you set Travis to cache any directories within the pyenv root, then you will probably break pyenv. For this reason, Python builds are cached outside the pyenv root and then linked after pyenv is installed.
