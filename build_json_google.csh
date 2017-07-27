#!/bin/csh
cd images/google
set FILES=`ls *.json`
cd ..
foreach FILE ($FILES)
	cat google/$FILE >$FILE
	cat provisioners/$FILE >>$FILE
	echo ',{"type": "shell","inline": [ "sudo sed -i'' -e \"s/ubuntu//g\" /var/lib/google/google_users" ] }' >>$FILE
	echo "]" >>$FILE
	echo "}" >>$FILE
end
