#!/bin/bash


case "$1" in

1)  echo "Starting Single node."
    sh nifi-1/bin/nifi.sh restart
    ;;
2)  echo  "Starting Two nodes."
    sh nifi-1/bin/nifi.sh restart
    sh nifi-2/bin/nifi.sh restart    
    ;;
3)  echo  "Starting Three node."
    sh nifi-1/bin/nifi.sh restart
    sh nifi-2/bin/nifi.sh restart
    sh nifi-3/bin/nifi.sh restart

    
    ;;
9) echo  "Sending SIGKILL signal"
   
   ;;
*) echo "Signal number $1 is not processed"
   ;;
esac
