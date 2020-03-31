#!/bin/bash -e

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

VERSION="2.4.10"
SHA256="93d06711795bfb76dbe7e765e82cdff3ddf9d82eff2a1f24dead9bb506eaf2d0"

[ "$1" = "--force" ] && FORCE=1 || FORCE=""

set -u

[ $UID -eq 0 ] || { echo "Root required"; exit 1; }

# Install Ruby and Bundler if they are missing or the force flag is set
if [ -n "$FORCE" ] || ! command -v ruby >/dev/null; then
  # wget: to fetch Ruby and pretty useful anyway
  # gcc & make: to compile Ruby
  # various libs: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install -y wget gcc make zlib1g-dev libssl-dev libreadline-dev libffi-dev
  elif [ -f /etc/redhat-release ]; then
    yum install -y wget gcc make zlib-devel openssl-devel readline-devel
  fi

  cd /tmp
  wget https://cache.ruby-lang.org/pub/ruby/${VERSION%.*}/ruby-${VERSION}.tar.gz
  echo "${SHA256}  ruby-${VERSION}.tar.gz" | sha256sum -c -
  tar --no-same-owner -xf ruby-${VERSION}.tar.gz

  pushd ruby-${VERSION}
  ./configure --disable-install-doc
  cpus=$(grep -c processor /proc/cpuinfo)
  make -j "$cpus"
  make install
  popd

  rm -rf ruby-${VERSION}.tar.gz ruby-${VERSION}

  ln -sfv /usr/local/bin/ruby /bin/ruby
  ln -sfv /usr/local/bin/gem /bin/gem

  ruby -v
  gem -v
fi

if [ -n "$FORCE" ] || ! command -v bundle >/dev/null; then
  gem install bundler --no-document

  ln -sfv /usr/local/bin/bundle /bin/bundle

  bundle -v
fi

echo "All good to go, happy Rubying!"
