#!/bin/bash

# ---------------------------------------------
# qcloud.sh
# Doug Rockney
# https://github.com/drockney/q
# v1.0 July 12, 2018
#
# See if the Q site is available.  If not,
# cloud API calls won't work.
# Let's change the Q key!
#
# Built from a local-signal code sample originally found at 
# https://www.daskeyboard.io/script-examples/send-signal-local/#shell
# ---------------------------------------------

# Keyboard settings
PID="DK5QPID" # product ID
ZONEID="KEY_Q" # Key to colorize
KEYCOLOR="F00" # I see a blank key and I want to paint it red
EFFECT="BREATHE" 

# Keyboard API settings
PORT=27301
APIURL="http://localhost:$PORT/api/1.0/signals"

# Remote check settings
REMOTEURL="https://q.daskeyboard.com" # site to check
QNAME="Q API down"
SLEEPYTIME=600 # Wait 10 minutes before checking again

function printHelp () {
      echo "$0 - watch a URL for a bad return code and change a key on a Das Keyboard 5Q"
      echo "Usage:"
      echo "    $0 -h"
      echo "			Display this help message."
      echo "    $0 -c <HEXCOLOR>"
      echo "			Color to change the key to, minus the octothorpe (defaults to $KEYCOLOR)"
      echo "    $0 -k <ZONEID>"
      echo "			5Q keyboard code we will be changing (defaults to $ZONEID)"
      echo "			see https://www.daskeyboard.io/q-api-doc/ for more info"
      echo "    $0 -t <seconds>"
      echo "			Wait <seconds> between checking <URL> state"
      echo "    $0 -u <URL>"
      echo "			Watch <URL> for error states."
}

# Check if the user wanted to have an argument or two
while getopts ":hc:k:t:u:" opt; do
  case ${opt} in
    h )
      printHelp
      exit 0
      ;;
    c )
      KEYCOLOR=$OPTARG
      ;;
    k )
      ZONEID=$OPTARG
      ;;
    t )
      SLEEPYTIME=$OPTARG
      ;;
    u )
      REMOTEURL=$OPTARG
      ;;
    \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     printHelp
     exit 1
     ;;
  esac
done

echo Checking $REMOTEURL every $(($SLEEPYTIME / 60)) minutes to make sure it is running...
while [ true ] ; do

	# Get the HTTP response code for the Q site.  This should usually be
	# less than 400 - series 200 and 300 responses are are usually OK/redirect types.
	response=$(curl --write-out %{http_code} --silent --output /dev/null $REMOTEURL)

	# If we have a problem, then change the color
	if [ $response -lt 200 -o $response -ge 400 ] ; then
		echo Whoops - $REMOTEURL unavailable at `date` - response code $response
		curl -s -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
		    "pid": "'"$PID"'",
		    "zoneId": "'"$ZONEID"'",
		    "color": "#'"$KEYCOLOR"'",
		    "effect": "'"$EFFECT"'",
		    "name": "'"$QNAME"'",
		    "message": "Message sent by script '$0'"
		}' $APIURL 2>&1 > /dev/null
	fi

	sleep $SLEEPYTIME

done
