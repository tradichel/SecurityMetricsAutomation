#!/bin/bash
payload=$(echo '{"github_repo":"dev.rainierrhododendrons.com"}' | base64)
echo $payload
aws lambda invoke --function-name dockertest out.txt --profile WebAdmin --payload $payload



