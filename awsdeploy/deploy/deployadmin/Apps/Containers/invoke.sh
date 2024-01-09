echo "Enter function name:"
read lambda_function
outfile="$lambda_function.txt"
echo "Enter AWS CLI profile: "
read profile

echo aws lambda invoke --function-name $function $outfile --profile $profile
aws lambda invoke --function-name $lambda_function $outfile --profile $profile
