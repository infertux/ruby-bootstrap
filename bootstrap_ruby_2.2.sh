#!/bin/bash -eu

# Download, configure and install Ruby and Bundler on a Debian-family or Redhat-family fresh system
# https://github.com/infertux/ruby-bootstrap

RUBY="2.2.2"
SHA256="5ffc0f317e429e6b29d4a98ac521c3ce65481bfd22a8cf845fa02a7b113d9b44"

# This runs as root on the server
[ $UID -eq 0 ]

set +u
[ -z "$TMUX" ] && {
  echo "You might want to \`apt-get install tmux' and run $0 from there. Press CTRL-C to cancel and do this."
  read
}
set -u

# Install Ruby and Bundler if we are on a vanilla system
command -v ruby >/dev/null || {
  # wget: to fetch Ruby and pretty useful anyway
  # gcc make: to compile Ruby
  # zlib1g-dev libssl-dev libreadline-dev: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install wget gcc make zlib1g-dev libssl-dev libreadline-dev libffi-dev
  elif [ -f /etc/redhat-release ]; then
    yum install wget gcc make zlib-devel openssl-devel readline-devel
  fi

  cd /tmp
  wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-${RUBY}.tar.gz
  echo "${SHA256}  ruby-${RUBY}.tar.gz" | sha256sum -c -
  tar xf ruby-${RUBY}.tar.gz

  cd ruby-${RUBY}/
  export CFLAGS=-fPIC # https://www.ruby-forum.com/topic/6654701
  ./configure --disable-install-doc
  cpus=$(grep -c processor /proc/cpuinfo)
  make -j $cpus
  make install

  rm -rf /tmp/ruby-${RUBY}
  cd

  ruby -v
}

command -v bundle >/dev/null || {
  gem install bundler --verbose --no-document

  bundle -v
}

echo "All good to go, happy Rubying!"

