#!/usr/bin/env sh

# Algumas dependencias de desenvolvimento são adicionadas,
# as dapendencias dos gems do limarka precisam ser compilados.
# https://github.com/travis-ci/travis.rb/issues/558

apt-get install -y -qq \
  gcc \
  libffi-dev \
  libfontconfig \
  locales \
  make \
  perl-doc \
  ruby-dev \
  unzip \
  wget
