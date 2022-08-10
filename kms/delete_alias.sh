#!/bin/sh

profile=kms
aliasname="$1"

aws kms delete-alias --alias-name $aliasname --profile $profile
