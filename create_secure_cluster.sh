#!/bin/bash
#set -x

export HOSTNAME=$HOSTNAME
export USERNAME=devadmin

case "$1" in

1)  echo "Creating Node one."

    NODENAME=$(cat hosts | grep node01 | awk -F"=" '{ print $2 }')    
    rm -Rf nifi-1 > /dev/null 2>&1
    cp -r nifi-0 nifi-1 

    ./create_certificate.sh 1

    cp certs/node01/* nifi-1/conf/
    
    sed -i '' "s/nifi.state.management.embedded.zookeeper.start=false/nifi.state.management.embedded.zookeeper.start=true/" nifi-1/conf/nifi.properties
    mkdir -p nifi-1/state/zookeeper/
    echo 1 > nifi-1/state/zookeeper/myid

    sed -i '' "s/^nifi.web.http.port=.*/nifi.web.http.port=/" nifi-1/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.host=.*/nifi.web.https.host=$NODENAME/" nifi-1/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.port=.*/nifi.web.https.port=9443/" nifi-1/conf/nifi.properties

    sed -i '' "s/nifi.remote.input.secure=.*/nifi.remote.input.secure=true/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.protocol.is.secure=.*/nifi.cluster.protocol.is.secure=true/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.address=.*/nifi.cluster.node.address=/" nifi-1/conf/nifi.properties

    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$NODENAME:2181/" nifi-1/conf/nifi.properties    
    sed -i '' "s/server.1=.*/server.1=$NODENAME:2885:3885;2181/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/nifi.cluster.is.node=false/nifi.cluster.is.node=true/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7777/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=1/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.wait.time=5 mins/nifi.cluster.flow.election.max.wait.time=1 mins/" nifi-1/conf/nifi.properties

    sed -i '' "s/<property name=\"Initial User Identity 1\"><\/property>/<property name=\"Initial User Identity 1\">CN=admin, OU=NIFI<\/property><property name=\"Initial User Identity 2\">CN=$NODENAME, OU=NIFI<\/property>/" nifi-1/conf/authorizers.xml
    sed -i '' "s/Initial Admin Identity\">/Initial Admin Identity\">CN="$USERNAME", OU=NIFI/" nifi-1/conf/authorizers.xml
    sed -i '' "s/Node Identity 1\">/Node Identity 1\">CN=$NODENAME, OU=NIFI/" nifi-1/conf/authorizers.xml

    sed -i '' "s/\"Connect String\">/\"Connect String\">$NODENAME:2181/" nifi-1/conf/state-management.xml

    #sh nifi-1/bin/nifi.sh restart & tail -f nifi-1/logs/nifi-app.log

    ;;
2)  echo  "Creating node two."
     
    sh create_secure_cluster.sh 1

    NODENAME=$(cat hosts | grep node02 | awk -F"=" '{ print $2 }')
    rm -Rf nifi-2 > /dev/null 2>&1
    cp -rf nifi-1 nifi-2    

    echo 2 > nifi-2/state/zookeeper/myid    
    
    sed -i '' "s/# server.2=.*/server.2=$NODENAME:2886:3886;2182/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/# server.2=.*/server.2=$NODENAME:2886:3886;2182/" nifi-2/conf/zookeeper.properties

    sed -i '' "s/^nifi.web.http.port=.*/nifi.web.http.port=/" nifi-2/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.host=.*/nifi.web.https.host=$NODENAME/" nifi-2/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.port=.*/nifi.web.https.port=9444/" nifi-2/conf/nifi.properties
   
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=2/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=2/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7778/" nifi-2/conf/nifi.properties
    
    sed -i '' "s/2181/2181,$NODENAME:2182/" nifi-1/conf/nifi.properties
    sed -i '' "s/2181/2181,$NODENAME:2182/" nifi-2/conf/nifi.properties
  
    sed -i '' "s/2181/2181,$NODENAME:2182/" nifi-1/conf/state-management.xml       
    sed -i '' "s/2181/2181,$NODENAME:2182/" nifi-2/conf/state-management.xml
    sed -i '' "s/nifi.cluster.load.balance.port=6342/nifi.cluster.load.balance.port=6343/" nifi-2/conf/nifi.properties

    # sh nifi-1/bin/nifi.sh restart 
    # sh nifi-2/bin/nifi.sh restart 
    # tail -f nifi-2/logs/nifi-app.log
    ;;

3)  echo  "Creating node three."
    sh create_secure_cluster.sh 2
    rm -Rf nifi-3 > /dev/null 2>&1
    
    cp -rf nifi-2 nifi-3

    NODENAME=$(cat hosts | grep node03 | awk -F"=" '{ print $2 }')

    echo 3 > nifi-3/state/zookeeper/myid

#    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$NODENAME:2887:3887;2183/" nifi-1/conf/zookeeper.properties
#    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-2/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$NODENAME:2887:3887;2183/" nifi-2/conf/zookeeper.properties
#    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-3/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$NODENAME:2887:3887;2183/" nifi-3/conf/zookeeper.properties

    sed -i '' "s/^nifi.web.http.port=.*/nifi.web.http.port=/" nifi-3/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.host=.*/nifi.web.https.host=$NODENAME/" nifi-3/conf/nifi.properties
    sed -i '' "s/^nifi.web.https.port=.*/nifi.web.https.port=9445/" nifi-3/conf/nifi.properties

    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-3/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7779/" nifi-3/conf/nifi.properties
    
    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-1/conf/nifi.properties
    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-2/conf/nifi.properties
    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-3/conf/nifi.properties

    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-1/conf/state-management.xml
    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-2/conf/state-management.xml
    sed -i '' "s/2182/2182,$NODENAME:2183/" nifi-3/conf/state-management.xml

    sed -i '' "s/nifi.cluster.load.balance.port=6343/nifi.cluster.load.balance.port=6344/" nifi-3/conf/nifi.properties

    ;;
9) echo  "Sending SIGKILL signal"
   
   ;;
*) echo "Signal number $1 is not processed"
   ;;
esac

