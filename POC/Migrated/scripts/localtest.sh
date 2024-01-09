#this file presumes you are running the local test from within the images/[function name] directory

image=$(basename "$PWD")
echo "Run: $image"

../../build.sh
docker run -p 9000:8080 $image:latest "job.handler"





