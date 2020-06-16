#!/usr/bin/env sh

quiet=0
PANDOC_DEB=https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-1-amd64.deb

while getopts "q" opt; do
  case $opt in
    q)
      quiet=1
      ;;
  esac
done

if [ $quiet eq 1 ]; then
  wget -nv $PANDOC_DEB
else
  wget -c $PANDOC_DEB
fi

sudo dpkg -i pandoc-*.deb && rm pandoc-*.deb
