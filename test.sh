#!/bin/sh

#test all the things

cd iam
./test.sh
cd ..

cd kms
./test.sh
cd ..

cd jobs
./test.sh
cd ..

echo "Test Complete"

