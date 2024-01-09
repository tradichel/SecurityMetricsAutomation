#!/bin/bash

function doit {

	test="$1"

  if [[ -z $test ]]; then
			echo "test not set"
  fi
 
}

echo "variable passed in"
doit "test"

echo "no parameters"
doit



