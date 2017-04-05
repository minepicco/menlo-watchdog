#!/bin/sh

# Iteration Interval (sec)
i=300

# email settings
smtp=""
fromadd=""  # From email address
toadd=""  # To email address (camma separated)
mtitle="Menlo Alert!"  # Email title
mbody="No Expected Access was found in past 5 mins!" # Email body

# Detection user and url
url="https://hub.docker.com/r/minepicco/mailserver/tags/"
usr="nohara-m@macnica.net"

while :
do
 a=`date +%s`
 b=$(( a-i ))

 curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"9d0bcfe4b7e14a6ba84c1940fa6247d0"}' 'https://logs.menlosecurity.com/api/rep/v1/fetch/client_select?format=JSON&start='$b | python -m json.tool > /home/nohara/menlo/menloout.txt

## email alerting
 cnt=`sed -e '1d'  /home/nohara/menlo/menloout.txt | sed -e '$d' | jq .result.events | grep $url -B2 | grep $usr -c`
 if [ $cnt -lt 1 ]; then
   /home/nohara/email/sendEmail-v1.56/sendEmail -f $fromadd -t $toadd -s $smtp -u $mtitle -m $mbody -a /home/nohara/menlo/menloout.txt
   sed -e '1d'  /home/nohara/menlo/menloout.txt | sed -e '$d' | jq .result.events | grep $url -B2 | grep $usr -c
 fi
 sleep $i

done
