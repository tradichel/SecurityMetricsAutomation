#configure a Function URL before making a curl request
echo "Enter URL:"
read url

curl -v $url \
-H 'content-type: application/json' \
-d '{ "example": "test" }'



