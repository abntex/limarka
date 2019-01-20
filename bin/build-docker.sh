# $1: limarka version

echo "Gerando imagem do limarka... $VERSION"
docker build -t limarka/limarka -f containers/Dockerfile-ruby-tinytex.production .
echo "Aplicando tags..."
docker tag limarka/limarka limarka/limarka:tinytext
docker images
