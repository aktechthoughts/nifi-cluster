#!/bin/bash


case "$1" in

1) 
    tail -f nifi-1/logs/nifi-app.log
    ;;
2) 
    tail -f nifi-2/logs/nifi-app.log    
    ;;
3) 
    tail -f nifi-3/logs/nifi-app.log
    ;;
*) echo "Signal number $1 is not processed"
   ;;
esac
