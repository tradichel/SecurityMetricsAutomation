#!/bin/bash
#@author @teriradichel @2ndsightlab

#use to schedule key deletion
keyid="$1"
profile="$2"

aws kms schedule-key-deletion --key-id $keyid --pending-window-in-days 7
