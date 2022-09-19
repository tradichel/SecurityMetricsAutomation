#!/bin/bash

source shared_functions.sh

	encryptarn="e"
  parameters=$(add_parameter_to_list "EncryptArnParam" $encryptarn)
	echo $parameters

	decryptarn="d"
  parameters=$(add_parameter_to_list "DecryptArnParam" $decryptarn "$parameters")
  echo $parameters

  keyalias="k"
	parameters=$(add_parameter_to_list "KeyAliasParam" $keyalias "$parameters")
  echo $parameters

	desc="Test spaces ok"
  parameters=$(add_parameter_to_list "DescParam" "$desc" "$parameters")
  echo $parameters

	conditionservice='work'
  parameters=$(add_parameter_to_list "ServiceParam" "$conditionservice" "$parameters")
  echo $parameters
