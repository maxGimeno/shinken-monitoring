#!/bin/bash
HOST=$1

cd /srv/CGAL/www/Manual_doxygen_test/
#get date of last modified file in directory
DateFromServer=$(stat -c %y $(ls -t|head -1))
#format the date in seconds since 1970
LAST_UPDATE=$(date -d "$DateFromServer" +%s) 
#format today's date in seconds since 1970
TODAY=$(date +"%s")
#compute the difference in days
DIFFERENCE=$(( ($TODAY - $LAST_UPDATE) / 86400 ))


if [ $DIFFERENCE -ne 0 ]; then
 echo "The last man page was uploaded $DateFromServer"
 result=$result+2
else
 echo "Manual page is up to date."
fi
