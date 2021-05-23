
# Creating Apache NiFi Cluster
NiFi cluster can be created in two modes - Secure and Insecure. Insecure mode is good for a quick POC, but as soon as we want to use NiFi for production we need secure NiFi

The scripts attached in this repository can be used to secure as well as insecure NiFi cluster. The scripts encapsulate all the details of configuration and make cluster creation process very easy. It can be used with ansible script for automation of NiFi cluster.

![Secure NiFi Cluster Architecture](images/NiFi_Cluster.png?raw=true "Secure NiFi Cluster Architecture")

We can follow below guide to create NiFi cluster in both the modes.


## Creating Insecure NiFi

**Prequsite**
- Download NiFi binary from [Here](https://nifi.apache.org/download.html).
- Extract the nifi-1.1x-bin.tar ball extracted as nifi-0 in root directory.

**Steps**

1. Execute the shell script in the root directory to create to create one/two/three node cluster.<br/>~$ sh create_insecure_cluster.sh <1/2/3>

2. Use below script to start the clusters, use parameter (1/2/3) as the required configuration.<br/>~$ sh start.sh <1/2/3>

3. To stop the cluster use the script stop.sh<br/>~$ sh stop.sh <1/2/3>
  
4. Use see nifi-app.log for 1st, 2nd or 3rd node.<br/>~$ sh status.sh <1/2/3>


## Creating Secure NiFi


**Prequsite**

- Download NiFi binary from [Here](https://nifi.apache.org/download.html).
- Extract the nifi-1.1x-bin.tar ball extracted as nifi-0 in root directory.
- Download nifi-toolkit binary from [Here](https://nifi.apache.org/download.html).
- nifi-toolkit-1.1x-bin.tar ball extracted as nifi-toolkit in root directory. 

1. Create one/two/three certificates inside certs directory using <br/>~$sh create_certificates.sh <1/2/3>

2. Use create_secure_cluster.sh to create one/two/three node cluster.sh <br/>~$create_secure_cluster.sh <1/2/3>

3. Use below script to start the clusters, use parameter (1/2/3) as the required configuration.<br/>~$ sh start.sh <1/2/3>

4. To stop the cluster use the script stop.sh<br/>~$ sh stop.sh <1/2/3>
  
5. Use see nifi-app.log for 1st, 2nd or 3rd node.<br/>~$ sh status.sh <1/2/3>

## Using Nginx as reverse proxy for NiFi.

We can use 

**STEP 1: Install Nginx on the machine which acts as a proxy.**

1. Install Nginx on ubuntu machine using this [link].(https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04)
2. Create secure NIFI cluster usint the steps given in "Creating Secure NiFi".
3. You can use sample nginx.conf configuration file in the nginx.

**STEP 2: Make nginx secure (https).**

1. Create a rsa key file using openssl, which available in most ubuntu machines.<br/>
     ~$openssl genrsa -out example.com.key 2048
2. Create a certificate sign request.<br/>
     openssl req -new -key example.com.key -out example.com.csr
3. Create a config file (example.com.ext) for the dns used in the nginx server. Use below configuration file.<br/><br/>

-----
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com

----

4. We need to sign the certificates using CA (Certificate authority) file used to make NiFi secure.<br/><br/>
Sign the certificate using existing CA (nifi-cert.pem)<br/>
    ~$openssl x509 -req -in example.com.csr  \
                 -CA nifi-cert.pem \
                 -CAkey nifi-key.key \
                 -CAcreateserial \
                 -out example.com.crt \
                 -days 825 -sha256 \
                 -extfile example.com.ext<br/>

The command generates - example.com.crt

5. Use example.com.key, example.com.crt and nifi-cert.pem in the nginx.conf. as given below.<br/><br/> 

ssl_certificate /home/nifi_user/nginx//example.com.crt;<br/>
ssl_certificate_key /home/nifi_user/nginx/example.com.key;<br/>
ssl_client_certificate /home/nifi_user/nginx/nifi-cert.pem;<br/><br/>

This step configures https on nginx using CA file, which is a self sign certificate.

6. Secure NiFi cluster requires users to send - admin.p12 created in the step "Creating Secure NiFi".<br/>
Use below directive in the nginx.conf.<br/><br/>

proxy_ssl_certificate /home/nifi_user/nginx/admin.crt;<br/>
proxy_ssl_certificate_key /home/nifi_user/nginx/admin.key;<br/>
proxy_ssl_trusted_certificate /home/nifi_user/nginx/nifi-cert.pem;<br/>

The files required in this step can be generated following below steps.<br/>

7. Generate proxy certificates and key<br/><br/>

     - Generate key from p12:  <br/>
     ~$openssl pkcs12 -in admin.p12 -nocerts -out admin.key<br/>
     - Generate cert from p12: <br/>
     ~$openssl pkcs12 -in admin.p12 -clcerts -nokeys -out admin.crt <br/>
     - Remove passphrase from key: <br/>
     ~$openssl pkcs12 -in admin.p12 -nocerts -out admin.key


