#!/bin/bash -e

# Download, configure and install Ruby and Bundler
# https://github.com/infertux/ruby-bootstrap

RUBY="2.2.4"
SHA256="b6eff568b48e0fda76e5a36333175df049b204e91217aa32a65153cc0cdcb761"

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
  # gcc make: to compile Ruby
  # zlib1g-dev libssl-dev libreadline-dev: libraries for Ruby

  if [ -f /etc/debian_version ]; then
    apt-get update
    apt-get install wget gcc make zlib1g-dev libssl-dev libreadline-dev libffi-dev
  elif [ -f /etc/redhat-release ]; then
    yum install wget gcc make zlib-devel openssl-devel readline-devel
  fi

  cd /tmp
  wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-${RUBY}.tar.gz
  echo "${SHA256}  ruby-${RUBY}.tar.gz" | sha256sum -c -
  tar --no-same-owner -xf ruby-${RUBY}.tar.gz

  cd ruby-${RUBY}/
  export CFLAGS=-fPIC # https://www.ruby-forum.com/topic/6654701
  ./configure --disable-install-doc
  cpus=$(grep -c processor /proc/cpuinfo)
  make -j $cpus
  make install

  rm -rf /tmp/ruby-${RUBY}
  cd

  ln -sfv /usr/local/bin/ruby /bin/ruby

  ruby -v
fi

if [ -n "$FORCE" ] || ! command -v bundle >/dev/null; then
  gem install bundler --verbose --no-document

  bundle -v
fi

echo "All good to go, happy Rubying!"

