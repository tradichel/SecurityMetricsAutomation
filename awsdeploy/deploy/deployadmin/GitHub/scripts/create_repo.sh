
echo "Enter owner name"
read owner

echo "Enter repo name"
read repo

#change this if you want to use a different directory
homedir="/home/ec2-user"
codedir="$homedir/code"

#create the code directory
if [ ! -d "$codedir" ]; then
  mkdir $codedir
fi

echo "Enter github access token:"
read -s GH_TOKEN
export GH_TOKEN=$GH_TOKEN

cd $codedir

#use the github cli to create the repo
#see the script in the same directory to install the cli
gh repo create "$owner/$repo" --private --add-readme --clone

#add a .gitignore file
echo "*.pem" > .gitignore
echo "*.log" >> .gitignore
echo "*.swp" >> .gitignore

git add .
git commit -m "Add .gitingore file"
git push

GH_TOKEN=""
unset GH_TOKEN
history -c


