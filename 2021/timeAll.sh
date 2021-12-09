#!/bin/bash

function displaytime {
  local T=$(($1/1000))
  local H=$((T/60/60))
  local M=$((T/60%60))
  local S=$((T%60))
  local MS=$(($1%1000))
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 || $H > 0 )) && printf '%dm ' $M
  (( $S > 0 || $M > 0 || $H > 0 )) && printf '%d.%03ds' $S $MS
  (( $H == 0 && $M == 0 && $S == 0 )) && printf '%dms\n' $MS
}

function printRiddle {
  riddle=$1
  echo -n "$riddle: "
  startTime=$(date +%s%0N)
  RESULT=$(prolog -q -s $riddle -t solve | tee >(cat - >&5))
  endTime=$(date +%s%0N)
  duration=$(( ($endTime-$startTime)/1000000 ))
  echo -e "\033[1A$riddle: $RESULT ($(displaytime $duration))"
}

exec 5>&1
for riddle in $1*.prolog; do
  printRiddle $riddle
done
