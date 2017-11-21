#!/bin/bash
HOST=$1
wget --spider $HOST --user="$CGAL_USER" --password="$CGAL_PASSWD" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Access error"
  exit 2
else
  echo "Page is accessible."
  exit 0
fi
