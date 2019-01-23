# $1: comando valor
# tag v1.2.3
# branch master

# http://codewiki.wikidot.com/shell-script:if-else
if [ "$1" = "tag" ]
then
  # Versionamento Semântico 2.0.0
  # https://semver.org/lang/pt-BR/
  if [ -n "$2" ]
  then
    # Versionamento Semântico 2.0.0
    # https://semver.org/lang/pt-BR/
    MAJOR=`echo $2|cut -f 1 -d '.'`
    MINOR=`echo $2|cut -f 2 -d '.'`
    #PATCH=`echo $1|cut -f 3 -d '.'`
    echo "Aplicando tags de versão..."
    echo docker tag limarka "limarka/limarka"
    echo docker tag limarka "limarka/limarka:$MAJOR"
    echo docker tag limarka "limarka/limarka:$MAJOR.$MINOR"
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    echo docker push "limarka/limarka"
    echo docker push "limarka/limarka:$MAJOR"
    echo docker push "limarka/limarka:$MAJOR.$MINOR"
  else
    >&2 echo "Erro: faltou informar o nome da tag. Ex: tag v1.2.3"
    exit 1
  fi
elif [ "$1" = "branch" ]
then
  if [ -n "$2" ]
  then
    echo "Aplicando tag de branch..."
    echo docker tag limarka limarka/limarka:$2
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    echo docker push limarka/limarka:$2
  else
    >&2 echo "Erro: faltou informar o nome da tag para branch. Ex: branch dev"
    exit 1
  fi
else
  >&2 echo "Erro: faltou passar os parâmetros."
  >&2 echo "Uso:"
  >&2 echo "  tag v1.2.3"
  >&2 echo "  branch dev"
  exit 1
fi
