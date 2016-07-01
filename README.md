# travis-pypy
Set up a more recent [PyPy](http://pypy.org) to use in [Travis CI](https://travis-ci.org).

The Travis CI build images currently contain a very old version of PyPy which breaks a bunch of Python modules. This repository contains a script that can be used to set up a newer version of PyPy in your Travis CI builds using [pyenv](https://github.com/yyuu/pyenv).

## Usage
1. Set the `$PYPY_VERSION` environment variable to the version of PyPy to install.
2. Tell Travis to cache the `$HOME/.pyenv_cache` directory.
3. Download and source the script in `before_install`.

There are a few install options that can be set via environment variables:
* `PYPY_VERSION`
    Version of PyPy2 to install [required]
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
    - python: "2.7"
    - python: "pypy"
      env: PYPY_VERSION="5.3.1"
cache:
  - pip
  - directories:
    - $HOME/.pyenv_cache

before_install:
  - |
      if [[ -n "$PYPY_VERSION" ]]; then
        wget https://github.com/praekeltfoundation/travis-pypy/releases/download/0.1.0/setup-pypy.sh
        source setup-pypy.sh
      fi

script:
  - py.test my_project
```

## Notes
* Installing pyenv by downloading a release tag rather than cloning the git repo can make your builds a bit faster in some cases. Set the `PYENV_RELEASE` environment variable to achieve that.
* pyenv fails to install properly if ~/.pyenv is present, even if the directory is empty. So if you cache any directories within ~/.pyenv then you will probably break pyenv.
