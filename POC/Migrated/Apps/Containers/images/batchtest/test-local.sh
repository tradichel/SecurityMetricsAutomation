echo "Enter code: "
read -s code

echo "Executing...please wait."
event='{"github_repo":"dev.rainierrhododendrons.com","token":"'$code'"}'
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d $event
echo "Done."



