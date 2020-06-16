#!/usr/bin/env sh
# $1: limarka version
echo "Gerando imagem do limarka..."
docker build -t ruby-latex-pandoc . -f containers/ruby-latex-pandoc.dockerfile
docker build -t limarka - < containers/limarka.dockerfile
docker images
