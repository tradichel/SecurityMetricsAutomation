#!/bin/bash -e
# https://github.com/tradichel/SecurityMetricsAutomation
# Git/git_functions.sh
# author: @teriradichel @2ndsightlab
##############################################################
source ../Functions/shared_functions.sh

#change this if you want to use a different directory
homedir="/home/ec2-user"
codedir="$homedir/code"

create_repository(){
	owner=$1
	repo=$2

  function=${FUNCNAME[0]}
  validate_param "owner" "$owner" $function
  validate_param "repo" "$repo" $function

	#create the code directory if it doesn't exist
	if [ ! -d "$codedir" ]; then
		echo "Create code dir: $codedir"
  	mkdir $codedir
	fi

	echo "Enter github access token:"
	read -s GH_TOKEN
	export GH_TOKEN=$GH_TOKEN

	echo "Change to the code directory: $codedir"
	cd $codedir

  echo "Checking to see if repository exists:"
	#use the github cli to create the repo
	#see the script in the same directory to install the cli
	testrepo=$(gh repo list $owner | grep "$repo" || true)
	gh repo list $owner | grep "$repo" || true

	if [ "$testrepo" == "" ]; then
		echo "Creating repository"
		gh repo create "$owner/$repo" --private --add-readme --clone
	fi

  echo "Change to repository directory"
  cd $repo

  GH_TOKEN=""
  unset GH_TOKEN

	echo "switch to git command line"
	echo "set credential.helper to cache"
  git config credential.helper 'cache --timeout=240'

	echo "git fetch all"
	echo "If you do not do this - all kind of errors."
	echo "Something is defaulting to master that should default to main."
	echo "Likely some legacy code needs to be cleaned up after main branch name change."
	git fetch --all
	
	echo "checkout main"
	git checkout main

	echo "Add git .ignorefile to $owner/$repo"
	echo "*.pem" > .gitignore
	echo "*.log" >> .gitignore
	echo "*.swp" >> .gitignore

	git add .
	m="Add .gitingore file"
	git commit -m "$m"
	git push -u --set-upstream origin main

	history -c
}

check_in(){
  repo="$1"
	message="$2"

  function=${FUNCNAME[0]}
  validate_param "message" "$message" $function
  validate_param "repo" "$repo" $function

	cd "$codedir/$repo"
  
	echo "switch to git command line"
  echo "set credential.helper to cache"
  git config credential.helper 'cache --timeout=240'
	
	git pull
	git add .
	git commit -m "$message"
	git push

}

check_in_and_deploy(){
	repo="$1"
	message="$2"

	check_in "$1" "$2"

	echo "Add code to deploy the code here."

}

