#!/bin/bash

set -x



case "$1" in

1)  echo "Starting single node."

    rm -Rf nifi-1 > /dev/null 2>&1
    cp -r nifi-0 nifi-1 
    
    sed -i '' "s/nifi.state.management.embedded.zookeeper.start=false/nifi.state.management.embedded.zookeeper.start=true/" nifi-1/conf/nifi.properties
    mkdir -p nifi-1/state/zookeeper/
    echo 1 > nifi-1/state/zookeeper/myid

    sed -i '' "s/^nifi.web.http.host=.*/nifi.web.http.host=$HOSTNAME/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181/" nifi-1/conf/nifi.properties    
    sed -i '' "s/server.1=.*/server.1=$HOSTNAME:2885:3885;2181/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/nifi.cluster.is.node=false/nifi.cluster.is.node=true/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7777/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=1/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.wait.time=5 mins/nifi.cluster.flow.election.max.wait.time=1 mins/" nifi-1/conf/nifi.properties

    #sh nifi-1/bin/nifi.sh restart & tail -f nifi-1/logs/nifi-app.log

    ;;
2)  echo  "Starting two nodes."
     
    sh create_secure_cluster.sh 1
    rm -Rf nifi-2 > /dev/null 2>&1
    cp -rf nifi-1 nifi-2    

    echo 2 > nifi-2/state/zookeeper/myid    
    
    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-2/conf/zookeeper.properties

    sed -i '' "s/^nifi.web.http.port=.*/nifi.web.http.port=8081/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=2/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=2/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7778/" nifi-2/conf/nifi.properties
    
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181,$HOSTNAME:2182/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181,$HOSTNAME:2182/" nifi-2/conf/nifi.properties
  
    sed -i '' "s/\"Connect String\">/\"Connect String\">$HOSTNAME:2181,$HOSTNAME:2182/" nifi-1/conf/state-management.xml       
    sed -i '' "s/\"Connect String\">/\"Connect String\">$HOSTNAME:2181,$HOSTNAME:2182/" nifi-2/conf/state-management.xml
    sed -i '' "s/nifi.cluster.load.balance.port=6342/nifi.cluster.load.balance.port=6343/" nifi-2/conf/nifi.properties


    # sh nifi-1/bin/nifi.sh restart 
    # sh nifi-2/bin/nifi.sh restart 
    # tail -f nifi-2/logs/nifi-app.log

    ;;
3)  echo  "Starting three node."
    sh create_secure_cluster.sh 2
    rm -Rf nifi-3 > /dev/null 2>&1
    
    cp -rf nifi-2 nifi-3

    echo 3 > nifi-3/state/zookeeper/myid

    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-1/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$HOSTNAME:2887:3887;2183/" nifi-1/conf/zookeeper.properties

    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-2/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$HOSTNAME:2887:3887;2183/" nifi-2/conf/zookeeper.properties

    sed -i '' "s/# server.2=.*/server.2=$HOSTNAME:2886:3886;2182/" nifi-3/conf/zookeeper.properties
    sed -i '' "s/# server.3=.*/server.3=$HOSTNAME:2887:3887;2183/" nifi-3/conf/zookeeper.properties

    sed -i '' "s/^nifi.web.http.port=.*/nifi.web.http.port=8082/" nifi-3/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.cluster.flow.election.max.candidates=.*/nifi.cluster.flow.election.max.candidates=3/" nifi-3/conf/nifi.properties
    sed -i '' "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=7779/" nifi-3/conf/nifi.properties
    
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-1/conf/nifi.properties
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-2/conf/nifi.properties
    sed -i '' "s/nifi.zookeeper.connect.string=.*/nifi.zookeeper.connect.string=$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-3/conf/nifi.properties

    sed -i '' "s/\"Connect String\">/\"Connect String\">$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-1/conf/state-management.xml
    sed -i '' "s/\"Connect String\">/\"Connect String\">$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-2/conf/state-management.xml
    sed -i '' "s/\"Connect String\">/\"Connect String\">$HOSTNAME:2181,$HOSTNAME:2182,$HOSTNAME:2183/" nifi-3/conf/state-management.xml

    sed -i '' "s/nifi.cluster.load.balance.port=6343/nifi.cluster.load.balance.port=6344/" nifi-3/conf/nifi.properties
    ;;
9) echo  "Sending SIGKILL signal"
   
   ;;
*) echo "Signal number $1 is not processed"
   ;;
esac

