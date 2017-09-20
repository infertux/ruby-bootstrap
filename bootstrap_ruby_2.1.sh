#!/bin/bash -eu

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

RUBY="2.1.10"
SHA256="fb2e454d7a5e5a39eb54db0ec666f53eeb6edc593d1d2b970ae4d150b831dd20"

[ $UID -eq 0 ] || { echo "Root required"; exit 1; }

# Install Ruby and Bundler if we are on a vanilla system
command -v ruby >/dev/null || {
  # wget: to fetch Ruby and pretty useful anyway
  # gcc make: to compile Ruby
  # zlib1g-dev libssl-dev libreadline-dev: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install -y wget gcc make zlib1g-dev libssl1.0-dev openssl libreadline-dev libffi-dev
  elif [ -f /etc/redhat-release ]; then
    yum install -y wget gcc make zlib-devel openssl-devel readline-devel
  fi

  cd /tmp
  wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-${RUBY}.tar.gz
  echo "${SHA256}  ruby-${RUBY}.tar.gz" | sha256sum -c -
  tar --no-same-owner -xf ruby-${RUBY}.tar.gz

  cd ruby-${RUBY}/
  ./configure --disable-install-doc
  cpus=$(grep -c processor /proc/cpuinfo)
  make -j "$cpus"
  make install

  rm -rf /tmp/ruby-${RUBY}
  cd

  ln -sfv /usr/local/bin/ruby /bin/ruby
  ln -sfv /usr/local/bin/gem /bin/gem

  ruby -v
  gem -v
}

command -v bundle >/dev/null || {
  gem install bundler --no-document

  ln -sfv /usr/local/bin/bundle /bin/bundle

  bundle -v
}

echo "All good to go, happy Rubying!"
