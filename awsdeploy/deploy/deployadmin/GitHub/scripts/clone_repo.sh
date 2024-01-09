#!/bin/bash -e

#replace the following with the path where you want to clone the repos
gitdir='/path/to/clone/dir'
echo "Is this the correct directory where you want to clone the code: $gitdir ? (Ctrl-C to exit. Enter to continue.)"
read ok

#replace with the owner of the repo
#in my case https://github.com/tradichel, the owner is tradichel
owner='your-repo-owner-name'
echo "Is this the correct repository owner name: $owner ? (Ctrl-C to exit. Enter to continue.)"
read ok

#replace the repos below with your repo names
#for this example: https://github.com/tradichel/SecurityMetricsAutomation
#the repo name is SecurityMetricsAutomation
declare -a repos=('repo1' 'repo2' 'repo3')
echo "Is the list of repos correct? (Ctrl-C to exit. Enter to continue.)"
printf '%s\n' "${repos[@]}"
read ok

if [ ! -d "$gitdir" ]; then
  c="mkdir $gitdir"
  ($c)
fi

function sync(){
  repo=$1
  cd $gitdir
  git clone https://github.com/$owner/$repo.git
  cd $repo
  git remote set-url origin https://github.com/$owner/$repo.git
}

git config --global credential.helper 'cache --timeout 120'

for repo in "${repos[@]}"
do
   echo "clone repo $repo"
   sync $repo
done

#clear the credentials from cache
git credential-cache exit

#clear anything in bash history
history -c
