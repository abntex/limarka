# $1: comando valor
#   v1.2.3
#   dev
# http://codewiki.wikidot.com/shell-script:if-else
if [ -n = "$1" ]
then
    # Versionamento ANO.MÊS
    # https://semver.org/lang/pt-BR/
    ANO=`echo $1|cut -f 1 -d '.'`
    MES=`echo $2|cut -f 2 -d '.'`
    declare -a tags=("limarka/limarka" "limarka/limarka:$ANO" "limarka/limarka:$ANO.$MES")
else
    declare -a tags=("limarka/limarka:dev")
fi

echo "Aplicando tags: ${tags[*]}..."
for tag in "${tags[@]}"; do
  docker tag limarka "$tag"
done
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
for tag in "${tags[@]}"; do
  docker push "$tag"
done
