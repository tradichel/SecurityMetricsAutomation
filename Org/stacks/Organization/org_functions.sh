

create_organization(){

	id=$(get_organization_id)
	if [ "$id" == "" ]; then
		aws organizations create-organization
	else
		echo "Organization already exists: $id"
	fi
}

get_root_id(){
	rootouid=$(aws organizations list-roots --query Roots[0].Id --output text)
	echo $rootouid
}

get_ou_id(){
	 ouname=$1

   ouid=$(aws organizations list-organizational-units-for-parent --parent-id $rootouid \
     --query 'OrganizationalUnits[?Name==`'$ouname'`].Id' --output text)

	 echo $ouid

}

enable_scps(){
	
	enabled=$(aws organizations describe-organization --query \
		 'Organization.AvailablePolicyTypes[?Type==`SERVICE_CONTROL_POLICY`].Status' --output text)
	
	if [ "$enabled" == "Enabled" ]; then
		echo "SCPs are already enabled."
  else
		rootouid=$(get_root_id)
 	 	aws organizations enable-policy-type --root-id $rootouid --policy-type SERVICE_CONTROL_POLICY
	fi

}

get_organization_id(){
	orgid=$(aws organizations describe-organization --query 'Organization.Id' --output text)
	echo $orgid
}
