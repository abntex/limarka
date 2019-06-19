# $1: limarka version
echo "Gerando imagem do limarka..."
docker build -t ruby-latex-pandoc - < containers/ruby-latex-pandoc.dockerfile
docker build -t limarka - < containers/limarka.dockerfile
docker images
