source ../../../Functions/shared_functions.sh

profile="KMS"

users=$(get_users_in_group $group $profile)
decryptarns=$users
