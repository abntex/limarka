# $1: limarka version

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push limarka/limarka
docker push limarka/limarka:tinytext
