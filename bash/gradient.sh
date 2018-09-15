#!/bin/bash

# -----------------------------------
# gradient.sh
# Doug Rockney
# https://github.com/drockney/q
# v0.1 September 14, 2018
#
# Fade keys from one color to another
# across the keybaord
# -----------------------------------
# The keyboard is typically 24 columns wide including the side pipes
kbdcolumns=24
# ...and 6 rows high
kbdrows=6

# Keyboard settings
PID="DK5QPID" # product ID
ZONEID="KEY_Q" # Key to colorize
KEYSTARTCOLOR="F00" # I see a blank key and I want to paint it red
KEYENDCOLOR="00F" # End pattern
EFFECT="BREATHE" 

# Keyboard API settings
PORT=27301
APIURL="http://localhost:$PORT/api/1.0/signals"

function printHelp () {
      echo "$0 - fade the keyboard from one color on the left to another color on the right"
      echo ""
      echo "Usage:"
      echo "    $0 -h"
      echo "			Display this help message."
      echo "    $0 -s <HEXCOLOR>"
      echo "			starting color in hex, minus the octothorpe (defaults to $KEYSTARTCOLOR)"
      echo "    $0 -e <HEXCOLOR>"
      echo "			Color in hex to change the key to, minus the octothorpe (defaults to $KEYENDCOLOR)"
      echo "    $0 -k <ZONEID>"
      echo "			5Q keyboard code we will be changing (defaults to $ZONEID)"
      echo "			see https://www.daskeyboard.io/q-api-doc/ for more info"
      echo "Unlike a truly robust shell script, I do no error-checking or input validation."
}

# Check if the user wanted to have an argument or two
while getopts ":hs:e:k:" opt; do
  case ${opt} in
    h )
      printHelp
      exit 0
      ;;
    s )
      KEYSTARTCOLOR=$OPTARG
      ;;
    e )
      KEYENDCOLOR=$OPTARG
      ;;
    \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     printHelp
     exit 1
     ;;
  esac
done

# calculate red, green, and blue step count
redstart=$((16#${KEYSTARTCOLOR:0:1}))
redend=$((16#${KEYENDCOLOR:0:1}))
redtotal=$(($redend - $redstart))
greenstart=$((16#${KEYSTARTCOLOR:1:1}))
greenend=$((16#${KEYENDCOLOR:1:1}))
greentotal=$(($greenend - $greenstart))
bluestart=$((16#${KEYSTARTCOLOR:2:1}))
blueend=$((16#${KEYENDCOLOR:2:1}))
bluetotal=$(($blueend - $bluestart))
if [ "$redtotal" -ne "0" ] ; then
  redstep=`echo "scale=5;$redtotal / $kbdcolumns" | bc`
  if [ "$redtotal" -lt "0" ] ; then
    redstep="-0.${redstep:2:5}"
  else
    redstep="0.${redstep:1:5}"
  fi
else
  redstep=0
fi
if [ "$greentotal" -ne "0" ] ; then
  greenstep=`echo "scale=5;$greentotal / $kbdcolumns" | bc`
  if [ "$greentotal" -lt "0" ] ; then
    greenstep="-0.${greenstep:2:5}"
  else
    greenstep="0.${greenstep:1:5}"
  fi
else
  greenstep=0
fi
if [ "$bluetotal" -ne "0" ] ; then
  bluestep=`echo "scale=5;$bluetotal / $kbdcolumns" | bc`
  if [ "$bluetotal" -lt "0" ] ; then
    bluestep="-0.${bluestep:2}"
  else
    bluestep="0.${bluestep:1}"
  fi
else
  bluestep=0
fi

echo -n "Queueing changes"
array=()
for i in `seq 0 $kbdcolumns` ; do
    # Set the color for the current column
    redvalue=`echo "ibase=10;obase=16;scale=0;$redstart + ($redstep * $i)" | bc`
    redvalue=${redvalue:0:1}
    if [ "$redvalue" == "." ] ; then
      redvalue=0
    fi
    greenvalue=`echo "ibase=10;obase=16;scale=0;$greenstart + ($greenstep * $i)" | bc`
    greenvalue=${greenvalue:0:1}
    if [ "$greenvalue" == "." ] ; then
      greenvalue=0
    fi
    bluevalue=`echo "ibase=10;obase=16;scale=0;$bluestart + ($bluestep * $i)" | bc`
    bluevalue=${bluevalue:0:1}
    if [ "$bluevalue" == "." ] ; then
      bluevalue=0
    fi
    printf -v keycolor "%X%X%X" 0x${redvalue:0:1} 0x${greenvalue:0:1} 0x${bluevalue:0:1}
    if [ "$i" -eq "5" ] ; then
      spacebarcolor=$keycolor
    fi
    echo -n '.'
    for j in `seq 0 $kbdrows`
    do
        array+=(--next -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
            "pid": "'"$PID"'",
            "zoneId": "'"$i","$j"'",
            "color": "#'"$keycolor"'",
            "effect": "SET_COLOR"
        }' "$APIURL")
    done
done

# Clear the spacebar error catcher
array+=(--next -X DELETE ${APIURL}/pid/${PID}/zoneId/KEY_SPC)
array+=(--next -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
        "pid": "'"$PID"'",
        "zoneId": "5,7",
        "color": "#'"$spacebarcolor"'",
        "effect": "SET_COLOR"
}' "$APIURL")
echo ". complete.  Starting shift from $KEYSTARTCOLOR to $KEYENDCOLOR."
curl -s "${array[@]}" > /dev/null
