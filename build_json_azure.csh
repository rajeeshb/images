#!/bin/csh
cd images/azure
set FILES=`ls *.json`
cd ..
foreach FILE ($FILES)
	cat azure/$FILE >$FILE
	cat provisioners/$FILE >>$FILE
	echo ',{"type": "shell","inline": [ "sudo /usr/sbin/waagent -force -deprovision&& HISTSIZE=0 && sudo sync" ] }' >>$FILE
	echo "]" >>$FILE
	echo "}" >>$FILE
end
