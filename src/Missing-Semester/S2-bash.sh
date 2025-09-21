#!/bin/env bash

n=$(( RANDOM % 100 ))

if [[ $n -eq 42 ]]; then
  echo "Sth wrong"
  >&2 echo "the error was using magic numbers"
  exit 1
fi

echo "Everything went according to plan"
