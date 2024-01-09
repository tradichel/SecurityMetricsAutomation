

deploy_lambda(){

  functionname="$1"
  env="$2"
	secret="$3"

  function=${FUNCNAME[0]}
  validate_param "functionname" "$functionname" "$function"
  validate_param "env" "$env" "$function"

  p=$(add_parameter "NameParam" $functionname)
  p=$(add_parameter "EnvParam" $env $p)

  template='cfn/Lambda.yaml'
  resourcetype='Lambda'

  deploy_stack $profile $functionname $resourcetype $template "$p"
	
	if [ "$secret" == "true" ]; then
	
		#change_dir "Key"
		kmskeyid=$(get_kms_key_id $env'Key')

		if [ "$kmskeyid" == "" ]; then
  		echo "KMS key id is not set." 1>&2
  		exit 1
		fi

		echo "KMS Key ID: $kmskeyid"

		acctid=$(get_account_id)	
		readonlyroles='arn:aws:iam::'$acctid:role/$functionname'LambdaRole'
		secretname=$functionname'Secret'
		change_dir "Secret"
		create_secret $secretname $kmskeyid $readonlyroles

	fi

}


