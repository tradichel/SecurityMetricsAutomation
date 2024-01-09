#/bin/bash

docker ps -a | cut -d " " -f1 > images.txt
while read p; do
 	docker rm $p
done <images.txt

i="xxxxxxxxxxx.dkr.ecr.xx-xxxx-xx.amazonaws.com/sandbox"
docker images | grep "$i" | cut -d " " -f70 | sort | uniq > images.txt
while read p; do
  docker rm $p
done <images.txt

docker images | grep '<none>' | cut -d " " -f70 | sort | uniq > images.txt
while read p; do
  docker image rm $p
done <images.txt
