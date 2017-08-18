#!/bin/bash
mkdir ~/Desktop/tempdir
cd ~/Desktop/tempdir
rm tempfile
rm tempfile2
rm tempfile3
echo -e "uid \t url \t id.orig_h \t id.resp_h \n" >> tempfile3
for g in /nsm/bro/extracted/*   # Find all bro file uids from extracted files
do
 checkval="$(ls $g | awk -F "-" '{print $2}' | cut -d "." -f1)" #cut the fuid from the filename and assign to variable
 for f in /nsm/bro/logs/*/files*.gz #iterate through the bro logs (This directory is for Security Onion installs, change for binary installs)
 do
  #Below we must zcat because of log rotation (note this doesn't look in current non gzipped. 
  #We then bro-cut what we want from the files.log 
  #then we must pass the variable checkval to AWK using  -v then if  the checkval is the same as the brocut fuid, we print the  fuid and the IPS
  #Just change this to write out to a file  > filename.h4x0r and now you can check to see where your users are getting all their awesome malware.
   zcat $f |  bro-cut fuid tx_hosts rx_hosts conn_uids | awk -v var=$checkval '{ if ($1 == var ) print $0}' >>  tempfile
 done
done
while read line; do echo "$line"; done < tempfile | awk '{print $4}' | sed 's/,/\n/g' >> tempfile2
while read line
do
 for h in /nsm/bro/logs/*/http*.gz
 do 
  zcat $h | bro-cut -d uid host uri id.orig_h id.resp_h | grep "$line" | awk -v OFS="\t" '{print $1, "http://"$2$3, $4, $5}' >> tempfile3
 done
done < tempfile2
while read line
do
 filevar="$(echo "$line" | cut -f2 | sed  's/.*\///')"
 if [[ "${filevar}" == *"GoogleUpdateSetup"* ]]; then
  echo "Progematically removed from wanted downloads"
 elif [[ "${filevar}" == *"url"* ]]; then
  echo "Ignore header"
 else
  if [ -f $filevar ]; then
   :
  else
   wget "$(echo "$line" | cut -f2)"
  fi
 fi
done < tempfile3

