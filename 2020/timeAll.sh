#!/bin/bash

function printRiddle {
  riddle=$1
  echo -n "$riddle: "
  startTime=$(date +%s%0N)
  prolog -q -s $riddle -t solve
  endTime=$(date +%s%0N)
  duration=$(( ($endTime-$startTime)/1000000 ))
  echo " ($duration ms)"
}

for riddle in ?_?.prolog; do
  printRiddle $riddle
done
for riddle in ??_?.prolog; do
  printRiddle $riddle
done
