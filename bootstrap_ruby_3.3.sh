#!/bin/bash

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

set -euo pipefail

VERSION="3.3.8"
SHA256="5ae28a87a59a3e4ad66bc2931d232dbab953d0aa8f6baf3bc4f8f80977c89cab"

[ "${1:-}" = "--force" ] && FORCE=1 || FORCE=""

[ $UID -eq 0 ] || { echo "Root required"; exit 1; }

# Install Ruby and Bundler if they are missing or the force flag is set
if [ -n "$FORCE" ] || ! command -v ruby > /dev/null; then
  # Dependency list:
  # - wget: to fetch Ruby and pretty useful anyway
  # - gcc & make: to compile Ruby
  # - various libs: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install -y wget gcc make libffi-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev
  elif [ -f /etc/redhat-release ]; then
    yum install -y wget gcc make openssl-devel readline-devel zlib-devel
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
  ln -sfv /usr/local/bin/bundle /bin/bundle

  ruby -v
  gem -v
  bundle -v
fi

echo "All good to go, happy Rubying!"
