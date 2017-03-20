# travis-pyenv
With [Travis CI](https://travis-ci.org), sometimes you want to test your project code using an unsupported Python build, such as an exact version of [CPython](http://www.python.org), a more recent version of [PyPy](http://pypy.org), or any number of other Python implementations. You can use [pyenv](https://github.com/yyuu/pyenv) to install a very specific Python version or distribution, but setting it up properly in a Travis CI build environment can be tricky. This repo contains a script ([`setup-pyenv.sh`](setup-pyenv.sh)) you can download and call in your `.travis.yml` configuration to simplify this process.

## Usage
1. Set the `$PYENV_VERSION` environment variable to the Python to install.
2. Tell Travis to cache the `$HOME/.pyenv_cache` directory OR (optionally) some other directory you specify in the `$PYENV_CACHE_PATH` environment variable.
3. Download and source the `setup-pyenv.sh` script in `before_install`.
4. Build your project and run your tests as usual.

There are a few install options that can be set via environment variables:
* `PYENV_VERSION`
    The pyenv to install [required]
* `PYENV_VERSION_STRING`
    String to `fgrep` against the output of `python --version` to validate that the correct Python was installed (recommended) [default: none]
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
    - env: PYENV_VERSION=pypy-5.4.1 PYENV_VERSION_STRING='PyPy 5.4.1'
cache:
  - pip
  - directories:
    - $HOME/.pyenv_cache

before_install:
  - |
      if [[ -n "$PYENV_VERSION" ]]; then
        wget https://github.com/jthomale/travis-pyenv/raw/fullbuild/setup-pyenv.sh
        source setup-pyenv.sh
      fi

script:
  - py.test my_project
```

## Notes
* Installing pyenv by downloading a release tag rather than cloning the git repo can make your builds a bit faster in some cases. Set the `PYENV_RELEASE` environment variable to achieve that.
* If you want to use `$PYENV_CACHE_PATH`, you must also set up Travis to cache this directory in your Travis configuration. Using the cache is optional, but it can greatly speed up subsequent builds.
* pyenv fails to install properly if the `$PYENV_ROOT` is already present, even if the directory is empty. So if you set Travis to cache any directories within the pyenv root, then you will probably break pyenv. For this reason, Python builds are cached outside the pyenv root and then linked after pyenv is installed.
