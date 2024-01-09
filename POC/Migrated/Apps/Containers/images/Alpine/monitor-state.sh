#monitor the state of a container while pushing a new version to ECR
echo "Enter AWS CLI Profile"
read profile

for ((i=1; i<=1000; i++))
do
	aws lambda get-function --function-name "dockertest" --profile $profile | grep State | sed 's/,//'  
done


