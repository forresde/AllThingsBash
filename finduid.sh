#!/bin/bash
for g in /nsm/bro/extracted/*   # Find all bro file uids from extracted files
do
 checkval="$(ls $g | awk -F "-" '{print $2}' | cut -d "." -f1)" #cut the fuid from the filename and assign to variable
 for f in /nsm/bro/logs/*/files*.gz #iterate through the bro logs (This directory is for Security Onion installs, change for binary installs)
 do
  #Below we must zcat because of log rotation (note this doesn't look in current non gzipped. 
  #We then bro-cut what we want from the files.log 
  #then we must pass the variable checkval to AWK using  -v then if  the checkval is the same as the brocut fuid, we print the  fuid and the IPS
  #Just change this to write out to a file  > filename.h4x0r and now you can check to see where your users are getting all their awesome malware.
   zcat $f |  bro-cut fuid tx_hosts rx_hosts | awk -v var=$checkval '{ if ($1 == var ) print $0}'
 done
done

