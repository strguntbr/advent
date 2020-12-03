#!/bin/bash

javac at/ctrlbreak/advent/*.java
for file in $(ls at/ctrlbreak/advent/Riddle*.java); do
  riddle=$(echo "$file" | sed 's/\.java$//g' | sed 's/at\/ctrlbreak\/advent\///g')
  echo -n "$riddle: "
  java at.ctrlbreak.advent.$riddle
done
