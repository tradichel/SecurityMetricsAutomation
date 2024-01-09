#!/bin/bash -e

#manually get a copy of the source of this page:
#view-source:https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
#put it in src.html

resources_dir="../resources"

cat src.html | sed -e 's|<li>|\n<li>|g' -e 's|</li>|</li>\n|g' | grep "<li>" | grep "AWS" \
 | cut -d '/' -f2 | cut -d '.' -f1 | sed 's|AWS_||g' | tr '[:upper:]' '[:lower:]'  > svc.txt

while read s; do
	dir=$resources_dir'/'$s
	if [ ! -d "$dir" ]; then
  	mkdir $dir
	fi
done < svc.txt

rm svc.txt
rm src.html


