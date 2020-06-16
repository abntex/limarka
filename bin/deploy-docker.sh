#!/usr/bin/env sh

# $1: TAG
# http://codewiki.wikidot.com/shell-script:if-else
if [ -n "$1" ]
then
    # Versionamento ANO.MÊS
    # https://semver.org/lang/pt-BR/
    ANO=`echo $1|cut -f 1 -d '.'`
    MES=`echo $1|cut -f 2 -d '.'`
    rtptags="limarka/ruby-latex-pandoc limarka/ruby-latex-pandoc:$ANO limarka/ruby-latex-pandoc:$ANO.$MES"
    ltags="limarka/limarka limarka/limarka:$ANO limarka/limarka:$ANO.$MES"
else
    rtptags="limarka/ruby-latex-pandoc:dev"
    ltags="limarka/limarka:dev"
fi

echo "Aplicando tags..."
for tag in $rtptags
do
  docker tag ruby-latex-pandoc "$tag"
done
for tag in $ltags
do
  docker tag limarka "$tag"
done

echo "Publicando tags..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
for tag in $rtptags
do
  docker push "$tag"
done
for tag in $ltags
do
  docker push "$tag"
done
