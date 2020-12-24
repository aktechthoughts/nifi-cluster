#!/bin/bash
#set -x
mkdir -p certs

if [ ! -e "certs/nifi-cert.pem" ] || [ ! -e "certs/nifi-key.key" ] ; then
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o certs
fi

if [ -e "certs/"$HOSTNAME".p12" ] &&
   [ -e "certs/"$HOSTNAME".password" ] &&
   [ -e "certs/admin.p12" ] &&
   [ -e "certs/admin.password" ]; then
      exit
fi

case "$1" in

1)  echo "Creating certificate for Single node."

    rm -Rf certs/node*
    
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME \
          -P tsStorePasswod \
          -S ksStorePassword \
          -B admin \
          -C 'CN=admin,OU=NIFI' \
          -C "CN="$HOSTNAME",OU=NIFI" \
          -O

    mv certs/$HOSTNAME certs/node01
    mv certs/CN=admin_OU=NIFI.p12 certs/admin.p12
    mv certs/CN=admin_OU=NIFI.password certs/admin.password
    mv "certs/CN="$HOSTNAME"_OU=NIFI.p12" "certs/"$HOSTNAME".p12"
    mv "certs/CN="$HOSTNAME"_OU=NIFI.password" "certs/"$HOSTNAME".password"


    ;;
2)  echo "Creating certificate for Single node."
    
    rm -Rf certs/node*
    
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME\(2\) \
          -P tsStorePasswod \
          -S ksStorePassword \
          -B admin \
          -C 'CN=admin,OU=NIFI' \
          -C "CN="$HOSTNAME",OU=NIFI" \
          -O
    mv -f certs/$HOSTNAME certs/node01  
    mv -f certs/$HOSTNAME"_2" certs/node02 
    mv certs/CN=admin_OU=NIFI.p12 certs/admin.p12
    mv certs/CN=admin_OU=NIFI.password certs/admin.password
    mv "certs/CN="$HOSTNAME"_OU=NIFI.p12" "certs/"$HOSTNAME".p12"
    mv "certs/CN="$HOSTNAME"_OU=NIFI.password" "certs/"$HOSTNAME".password"

    ;;

3)  echo "Creating certificate for Single node."
  
    rm -Rf certs/node*
  
    ./nifi-toolkit/bin/tls-toolkit.sh standalone -o ./certs/ -n $HOSTNAME\(3\) \
          -P tsStorePasswod \
          -S ksStorePassword \
          -B admin \
          -C 'CN=admin,OU=NIFI' \
          -C "CN="$HOSTNAME",OU=NIFI" \
          -O
    mv -f certs/$HOSTNAME certs/node01 
    mv -f certs/$HOSTNAME"_2" certs/node02 
    mv -f certs/$HOSTNAME"_3" certs/node03

    mv certs/CN=admin_OU=NIFI.p12 certs/admin.p12
    mv certs/CN=admin_OU=NIFI.password certs/admin.password
    mv "certs/CN="$HOSTNAME"_OU=NIFI.p12" "certs/"$HOSTNAME".p12"
    mv "certs/CN="$HOSTNAME"_OU=NIFI.password" "certs/"$HOSTNAME".password"

    ;;


*) echo "Signal number $1 is not processed"
   ;;
esac


