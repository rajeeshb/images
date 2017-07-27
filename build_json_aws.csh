#!/bin/csh
cd images/aws
set FILES=`ls *.json`
cd ..
foreach FILE ($FILES)
	cat aws/$FILE >$FILE
	cat provisioners/$FILE >>$FILE
	echo "]" >>$FILE
	echo "}" >>$FILE
end
