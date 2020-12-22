
The scripts requires a nifi-0 which is simply extract of nifi-1.12.1-bin.tar.

1.) Use "sh create_secure_cluster.sh <1/2/3>" to create one/two/three node cluster.

2.) Use "sh start.sh <1/2/3>" to start one/two/three node cluster.

3.) Use "sh stop.sh <1/2/3>" to stop one/two/three node cluster.

4.) Use "sh status.sh <1/2/3>" to see nifi-app.log for 1st, 2nd or 3rd node.

5.) Use "sh create_certificates.sh <1/2/3>" to create one/two/three certificates inside certs directory(Used inside create_secure_cluster.sh ).
