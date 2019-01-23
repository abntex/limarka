# $1: limarka version
echo "Gerando imagem do limarka..."
docker build -t limarka -f containers/Dockerfile-ruby-tinytex.production .
docker images
