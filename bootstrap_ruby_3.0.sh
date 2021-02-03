#!/bin/bash -e

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

VERSION="3.0.0"
SHA256="a13ed141a1c18eb967aac1e33f4d6ad5f21be1ac543c344e0d6feeee54af8e28"

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
  ln -sfv /usr/local/bin/bundle /bin/bundle

  ruby -v
  gem -v
  bundle -v
fi

echo "All good to go, happy Rubying!"
