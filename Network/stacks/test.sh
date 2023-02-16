!/bin/bash -e

source network_functions.sh

deploy_remote_access_sgs_for_group "Developers" "RemoteAccessPublicVPC"
