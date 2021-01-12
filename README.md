
Insecure

Prequsite

  -- nifi-1.1x-bin.tar ball extracted as nifi-0 in root directory.

1.) Use "sh create_insecure_cluster.sh <1/2/3>" to create one/two/three node cluster.

2.) Use "sh start.sh <1/2/3>" to start one/two/three node cluster.

3.) Use "sh stop.sh <1/2/3>" to stop one/two/three node cluster.

4.) Use "sh status.sh <1/2/3>" to see nifi-app.log for 1st, 2nd or 3rd node.

5.) Use "sh create_certificates.sh <1/2/3>" to create one/two/three certificates inside certs directory(Used inside create_secure_cluster.sh ).


Secure
Prequsite

  -- nifi-1.1x-bin.tar ball extracted as nifi-0 in root directory.

  -- nifi-toolkit-1.1x-bin.tar ball extracted as nifi-toolkit in root directory. 

1.) Use "sh create_secure_cluster.sh <1/2/3>" to create one/two/three node cluster.

2.) Use "sh start.sh <1/2/3>" to start one/two/three node cluster.

3.) Use "sh stop.sh <1/2/3>" to stop one/two/three node cluster.

4.) Use "sh status.sh <1/2/3>" to see nifi-app.log for 1st, 2nd or 3rd node.

5.) Use "sh create_certificates.sh <1/2/3>" to create one/two/three certificates inside certs directory(Used inside create_secure_cluster.sh ).


####

Use below steps for using nginx as reverse proxy.

####


1.) Install nginx on ubuntu machine.

2.) Create secure NIFI cluster.

3.) Use the attached configuration file.

4.) Create a rsa key.
     openssl genrsa -out example.com.key 2048
5.) Create a certificate sign request.
     openssl req -new -key example.com.key -out example.com.csr
6.) Create config file (example.com.ext) using below

-----

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com

----

7.) Sign the certificate using existing CA (nifi-cert.pem)
    openssl x509 -req -in example.com.csr  \
                 -CA nifi-cert.pem \
                 -CAkey nifi-key.key \
                 -CAcreateserial \
                 -out example.com.crt \
                 -days 825 -sha256 \
                 -extfile example.com.ext

8.) Use example.com.key, example.com.crt and nifi-cert.pem as ssl_certificate, ssl_certificate_key and ssl_client_certificate respectively.

10.) Using existing user (admin) as proxy_ssl_certificate, proxy_ssl_certificate_key and 
     proxy_ssl_trusted_certificate.

     Generate key from p12:  openssl pkcs12 -in admin.p12 -nocerts -out admin.key
     Generate cert from p12: openssl pkcs12 -in admin.p12 -clcerts -nokeys -out admin.crt 
     Remove passphrase from key: openssl pkcs12 -in admin.p12 -nocerts -out admin.key


