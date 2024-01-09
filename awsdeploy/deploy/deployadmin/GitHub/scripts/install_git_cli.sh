#!/bin/bash

os=""
while [ "$os" != "1" ] && [ "$os" != "2" ]; do
  echo "Choose your platform"
  echo "1 AWS Linux"
  echo "2 Ubuntu"
  echo "for more: https://cli.github.com/manual/installation"
  echo "Ctrl-C to exit."
  read os
done

if [ "$os == "1" ]; then

  type -p yum-config-manager >/dev/null || sudo yum install yum-utils
  sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo yum install gh

fi

if [ "$os == "2" ]; then 
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

fi


