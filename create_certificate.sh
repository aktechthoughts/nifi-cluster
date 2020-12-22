#!/bin/bash
set -x
mkdir -p certs

if [ ! -e "certs/nifi-cert.pem" ] || [ ! -e "certs/nifi-key.key" ] ; then
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o certs
fi


case "$1" in

1)  echo "Creating certificate for Single node."
    
    rm -Rf certs/node*
    
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME \
          -P tsStorePasswod \
          -S ksStorePassword \
          -O
    mv certs/$HOSTNAME certs/node01

    ;;
2)  echo "Creating certificate for Single node."
    
    rm -Rf certs/node*
    
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME\(2\) \
          -P tsStorePasswod \
          -S ksStorePassword \
          -O
    mv -f certs/$HOSTNAME certs/node01  
    mv -f certs/$HOSTNAME"_2" certs/node02 

    ;;

3)  echo "Creating certificate for Single node."
  
    rm -Rf certs/node*
  
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME\(3\) \
          -P tsStorePasswod \
          -S ksStorePassword \
          -O
    mv -f certs/$HOSTNAME certs/node01 
    mv -f certs/$HOSTNAME"_2" certs/node02 
    mv -f certs/$HOSTNAME"_3" certs/node03
    ;;


*) echo "Signal number $1 is not processed"
   ;;
esac


