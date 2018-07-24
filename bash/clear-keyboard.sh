#!/bin/bash

# -----------------------------------
# clear-keyboard.sh
# Doug Rockney
# https://github.com/drockney/q
# v1.0 July 12, 2018
#
# Clear keyboard of all local signals
# Slow, because it's making individual
# calls for every single key
# -----------------------------------
# The keyboard is typically 24 columns wide including the side pipes
kbdcolumns=24
# ...and 6 rows high
kbdrows=6

# print a legend on top
echo -n '['
for i in `seq 1 $kbdcolumns` ; do
	echo -n '-'
done
echo ']'

echo -n ' '
for i in `seq 0 $(( $kbdcolumns - 1 ))` ; do
	echo -n '>'
	for j in `seq 0 $(( $kbdrows - 1 ))` ; do
		curl -s -X DELETE http://localhost:27301/api/1.0/signals/pid/DK5QPID/zoneId/$i,$j 2>&1 > /dev/null &
	done
done
echo ''
