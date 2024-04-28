
export HOSTNAME=`hostname`
# generate private key
export CERTNAME=`hostname -s`
export CANAME=CA-Cert

openssl genrsa -aes256 -out $CANAME.key 4096

# create certificate, 1826 days = 5 years
openssl req -x509 -new -nodes -key $CANAME.key -sha256 -days 1826 -out $CANAME.crt -subj '/C=US/ST=CA/L=SVL/O=IBM/OU=SWG/CN=Root CA'

# create certificate for service

openssl req -new -nodes -out $CERTNAME.csr -newkey rsa:4096 -keyout $CERTNAME.key -subj '/C=US/ST=CA/L=SVL/O=IBM/OU=SWG/CN=${HOSTNAME}'

# create a v3 ext file for SAN properties
cat > $CERTNAME.v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = hostname1.local
DNS.2 = hostname2.svc.local
IP.1 = 192.168.10.1
IP.2 = 192.168.12.1
EOF

openssl x509 -req -in $CERTNAME.csr -CA $CANAME.crt -CAkey $CANAME.key -CAcreateserial -out $MYCERT.crt -days 730 -sha256 -extfile $CERTNAME.v3.ext
