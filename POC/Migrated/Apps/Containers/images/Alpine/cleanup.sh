#!/bin/bash

while read p; do
  docker rm "$p"
done < containers.txt

while read p; do
  docker image rm "$p"
done <images.txt
