
tag=$1

docker build . -t aloisreitbauer/hello-server:$tag
docker push aloisreitbauer/hello-server:$tag  