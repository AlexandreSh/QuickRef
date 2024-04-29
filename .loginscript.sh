#!/bin/bash

export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

echo "DBUS_SESSION_BUS_ADDRESS set to: $DBUS_SESSION_BUS_ADDRESS"

####
#append this in ~/.profile of the user logging in with u2f
#  #script ran at login, currently fixes dbus errors for snaps
#  source /path/to/this/file/.loginscript.sh
#
