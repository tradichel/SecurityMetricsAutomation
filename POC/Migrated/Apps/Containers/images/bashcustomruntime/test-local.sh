
event='{"aws_repo":"dev.rainierrhododendrons.com"}'

curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d $event
echo "Done."



