#!/bin/bash

RESULT=$(ssh mgimeno@$1 mailq | grep -c "^[A-F0-9]")

if [ $RESULT -eq 0 ]; then
  echo "Mail queue is empty"
  exit 0;
elif [ $RESULT -gt 10 ]; then
  echo "There are $RESULT in the queue."
  exit 2
elif [ $RESULT -gt 2 ]; then
  echo "There are $RESULT in the queue."
  exit 1
fi


