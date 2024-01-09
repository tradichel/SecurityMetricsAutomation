#to make this work:

# -- Manually create the OrgRoot user and credentials
# -- Run container that creates org
# -- Creates new OrgAdmin account, user, role and delgates governance to it
# -- OrgAdmin deploys Sandbox env and SandboxAdmin
# -- OrgAdmin deploys Prod env and ProdAdmin
# -- ProdAdmin can push from Sandbox to Prod

# -- Each environment has what it needs to deploy - CodeCommit, ECR, networking, SCPs, etc.
# -- Full Org Structure under each branch
# -- Test first in SB then push SCPs to prod
# -- Test IDP and Prod IDP

# try to use this function below to 
function handler () {

  EVENT_DATA="$1"
  HEADERS="$2"

  RESPONSE='Event: "'$EVENT_DATA'"' 

  RESPONSE=$REPSONSE' Headers: "'$HEADERS'"' 

	#get these out of the event data
	repo="" #where to get the template code
	repo_creds="" #how to get the repo creds
  role="$1"
  resourcename="$2"
  resourcetype="$3"
  template="$4"
	mfacode="$5"

	#assume the specified role with the MFA code
	
	#create aws profile based on role
	
	#copy down the template based on Role + template name
	#In repo = [role]/cfn/[template]
	
  #adding brackets here to avoid repetitive code elsewhere
  parameters="[$5]"

	#what am I goingto do about this?
  #func=${FUNCNAME[0]}
  #validate_param 'profile' $profile $func
  #validate_param 'resourcename' "$resourcename" "$func"
  #validate_param 'resourcetype' "$resourcetype" "$func"
  #validate_param 'template' "$template" "$func"
  #not all stacks have parameters

  p=$(echo $profile | sed 's/-//')
  if [[ $p =~ ^[0-9] ]]; then
    echo "ERROR: Stack names must start with a letter"
		exit
  fi

  stackname=$p'-'$resourcetype'-'$resourcename
  status=$(get_stack_status $stackname)

  if [ "$status" == "ROLLBACK_COMPLETE" ]; then
    aws cloudformation delete-stack --stack-name $stackname --profile $profile
        while [ "$(get_stack_status $stackname)" == "DELETE_IN_PROGRESS" ]
        do
    sleep 5
    done
  fi

  echo "-------------- $stackname -------------------"
  c="aws cloudformation deploy --profile $profile 
      --stack-name $stackname 
      --template-file $template "

  #allowing IAM for all stacks; presume IAM Policies, SCPs, 
  #and Permission Boundaries will handle this, which is more appropriate  
  c=$c' --capabilities CAPABILITY_NAMED_IAM '

  if [ "$parameters" != "" ]; then
      c=$c' --parameter-overrides '$parameters
  fi
  echo $c

  e="display_stack_errors $stackname $profile"

  { ($c) } || { ($e) }

  echo $RESPONSE

}
