#delete all containers
docker rm -vf $(docker ps -aq)

#delete all images
docker rmi -f $(docker images -aq)
