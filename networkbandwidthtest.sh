#!/bin/bash
#Why not said the townspeople
#Dale Forrester
#
#Check bandwidth for local subnet using iperf3
#Installing....needs sudo
#Mostly needs sudo....make me a sandwich
#yes have some

clear
printf "Not so fancy iperf3 install and testing tool.\n"
printf "\n"
printf "Dale Forrester \n"

## DEFINE FILES SAVE LOCATIONS USER HOME DIRECTORY
mkdir ./iperf-results
ERRORLOG=./iperf-results/iperf-err.log
RESULTS=./iperf-results/NETWORK-DATA.csv
printf "timestamp,serverip,clientip,bandwidth(Mbps)\n" > $RESULTS # MAKE CSV HEADER
## END  DEFINING LOCATIONS

printf '%(%Y%m%d%H%M%S)T' >> $ERRORLOG
printf "\n" >> $ERRORLOG

if ! [ -n "$(command -v iperf3)" ]; then
 while true; do
  read -p "This will install iperf3 and possibly update your system. Proceed (Yy/Nn)? " yn
  case $yn in
   [Yy]*  ) break;;
   [Nn]* ) exit;;
  esac
 done


#Install iperf3

# Should I have only put the etc release in the error log once at the beginning....yeah probably.
 if [ -n "$(command -v yum)" ]; then
 echo "You use yum, that\'s very fun"
 if [ -n '$(cat /etc/*-release | grep -vi "centos")' ]; then
  echo "You use CentOS" >> $ERRORLOG
  cat /etc/*-release >> $ERRORLOG
  yum -y install epel-release
  yum -y update
  yum -y install iperf3
 else  
  echo "You dont use CentOS" >> $ERRORLOG
  cat /etc/*-release >> $ERRORLOG
  yum -y install iperf3
 fi
elif [ -n "$(command -v pacman)" ]; then
 echo "Arch Linux Detected" >> $ERRORLOG
 cat /etc/*-release >> $ERRORLOG
 pacman -S iperf3
elif [ -n "$(command -v emerge)" ]; then
 echo "Gentoo Linux...crazyman" >> $ERRORLOG
 cat /etc/*-release >> $ERRORLOG
 emerge iperf3
elif [ -n "$(command -v apt-get)" ]; then
 if [ -n '$(cat /etc/*-release | grep -vi "ubuntu")' ]; then
  echo "You use ubuntu" >> $ERRORLOG
  cat /etc/*-release >> $ERRORLOG
 fi
 echo "apt-get installed" >> $ERRORLOG
 apt-get -y install iperf3
fi
fi # END OF CHECKING AND INSTALLING IPERF
clear
printf "iperf3 is installed \n" >> $ERRORLOG

#Client or Server
printf "You need a client and server to make this work really well.\n"
printf "\n"


## FUNCTIONS ##

server(){
#things the server does
pkill -9 "iperf3"
echo "I am a server" >> $ERRORLOG
printf "Press Control C to terminate listening and return to menu \n"

iperf3 -s -p 5001 &
hostname -I
while true; do
  read -p "If you want to turn the server off, just hit Q or q. " q
  case $q in
   [Qq]*  ) break;;
  esac
done
pkill -9 "iperf3"

} #end of server

client(){
pkill -9 "iperf3"
#things the client does
echo "I am a client" >> $ERRORLOG
clear
## READ https://en.wikipedia.org/wiki/TCP_congestion_control#Slow_start
## READ https://iperf.fr/iperf-doc.php
printf "You are working on the client \n"
read -p "Enter the IP for the SERVER: " serverip
read -p "Please enter port number from SERVER : " portnum
# read -p Enter the size of the TCP window (suggested 64) : " wsize
#read -p Number of simultaneous connections to make: [numbers] : " parallel
read -p "Number of seconds to omit to prevent TCP slowstart [2 seconds is good] : " slowstart
hostname -I
read -p "Enter the IP of the computer you are presently on: (it's one of the choices listed above) : " clientip

## CREATE OUTPUT LOG FILE
TEMP=./iperf.temp
touch $TEMP
rm -rf $TEMP
##
printf '%(%Y%m%d%H%M%S)T' >> $ERRORLOG
printf "\n"
printf "The server IP is %s \n" "$serverip" >> $ERRORLOG
printf "The server port you entered is %s \n" >> $ERRORLOG
printf "The Window Size is %s \n" "$wsize" >> $ERRORLOG
printf "The number of simultaneous connections is %d \n" "$parallel" >> $ERRORLOG
printf "The number of seconds before starting or slowstart is %s \n" "$slowstart" >> $ERRORLOG

iperf3 -c $serverip -p $portnum -R -O $slowstart -f M  >>  $TEMP
timestamp="$(date -u +%s)"
bandwidth="$(cat $TEMP | grep "receiver" | awk -v OFS=" " '{print $7}' | tail -1)" # Just get the Megabytes per second
printf "$timestamp,$serverip,$clientip,$bandwidth" >> $RESULTS # Add data to the csv
printf "\n" >> $RESULTS #newline in csv
RAWOUTPUT=./iperf-results/iperf.rawoutput.$timestamp.json ## Want some cool JSON...this file is taken with the  EPOCH timestamp (it is of course run separately so the results may be varied from the CSV but you're taking averages anyhow...right?
iperf3 -c $serverip -p $portnum -R -O $slowstart -f M -J >> $RAWOUTPUT #output to JSON
rm -rf $TEMP
} #end of client

options(){
#what you get
local option
read -p "Enter your choice [ 1 - 3 ] " option
case $option in
 1) server ;;
 2) client ;;
 3) exit 0;;
 *) echo -e "${RED}Error ${STD}" && sleep 1
esac
} ## end of options

mainmenu(){
#what you see
clear
printf "o1oooooooooooooooo6ooooooooo \n"
printf "Why Not Said The Townspeople \n"
printf "oooooooo8oooooooooooooo5oooo \n"
printf "1. This is the server \n"
printf "2. This is the testing client \n"
printf "3. I need an adult and want to leave. \n"
} ## end of main menu

## END OF FUNCTIONS ##

## Main Function Call ##
while true
do
 mainmenu
 options
done
