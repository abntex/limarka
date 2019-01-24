# $1: limarka version
echo "Gerando imagem do limarka..."
docker build -t limarka/ruby-latex -f containers/Dockerfile-ruby-tinytex .
docker tag limarka/ruby-latex:latest limarka/ruby-latex:ruby2-tinytex
docker images
