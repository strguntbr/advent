#!/bin/bash

for riddle in $1*.prolog; do
  echo -n "$riddle: "
  prolog -q -s $riddle -t solve
done
