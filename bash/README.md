# Bash scripts
Tested with a Das Keyboard 5Q on a Windows 10 machine using Windows Subsystem for Linux (WSL) Ubuntu bash command line.

* clear-keyboard.sh - Crush, kill, and destroy all local Q signals.  Handy for deleting local signals quickly, since the Signal Center won't allow you to unset those via the "Delete All".
* gradient.sh - Set a color gradient on the keyboard. Defaults to going from red to blue, but accepts arguments.
* qcloud.sh - Check to see if the cloud API is available. If not, make the Q key breathe red.

## REQUIREMENTS
* curl is used to invoke the Q API
* bc is sometimes used for calculations
* If you have a 50Q, you'll need to change the PID in the script to match

## TODO
* Fix long-running piping of content to bc
* Fix clearing the spacebar when incorrectly setting a blank zoneId
