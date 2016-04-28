#!/bin/bash -e

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

VERSION="2.2.5"
SHA256="30c4b31697a4ca4ea0c8db8ad30cf45e6690a0f09687e5d483c933c03ca335e3"

[ "$1" = "--force" ] && FORCE=1 || FORCE=""

set -u

# This runs as root on the server
[ $UID -eq 0 ]

set +u
[ -z "$TMUX" ] && {
  echo "You might want to \`apt-get install tmux' and run $0 from there. Press CTRL-C to cancel and do this."
  read
}
set -u

# Install Ruby and Bundler if they are missing or the force flag is set
if [ -n "$FORCE" ] || ! command -v ruby >/dev/null; then
  # wget: to fetch Ruby and pretty useful anyway
  # gcc & make: to compile Ruby
  # various libs: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install wget gcc make zlib1g-dev libssl-dev libreadline-dev libffi-dev
  elif [ -f /etc/redhat-release ]; then
    yum install wget gcc make zlib-devel openssl-devel readline-devel
  fi

  cd /tmp
  wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-${VERSION}.tar.gz
  echo "${SHA256}  ruby-${VERSION}.tar.gz" | sha256sum -c -
  tar --no-same-owner -xf ruby-${VERSION}.tar.gz

  pushd ruby-${VERSION}
  export CFLAGS=-fPIC # https://www.ruby-forum.com/topic/6654701
  ./configure --disable-install-doc
  cpus=$(grep -c processor /proc/cpuinfo)
  make -j "$cpus"
  make install
  popd

  rm -rf ruby-${VERSION}.tar.gz ruby-${VERSION}

  ln -sfv /usr/local/bin/ruby /bin/ruby
  ruby -v
fi

if [ -n "$FORCE" ] || ! command -v bundle >/dev/null; then
  gem install bundler --verbose --no-document

  bundle -v
fi

echo "All good to go, happy Rubying!"

