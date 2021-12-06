#!/bin/bash

for riddle in *.prolog; do
  echo -n "$riddle: "
  prolog -q -s $riddle -t solve
  echo
done
