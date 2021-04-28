#! /bin/bash

DOMAIN=test1.zerchin.xyz
DOMAIN_EXT=
IP=172.16.1.188
DATE=3650

## generate CA : cakey.pem && cacerts.pem
if [[ ! -e "cacerts.pem" || ! -e "cakey.pem" ]]
then
  openssl genrsa -out cakey.pem 2048
  openssl req -x509 -new -nodes -key cakey.pem -subj "/CN=zerchin" -days ${DATE} -out cacerts.pem 
fi


## generate server tls
mkdir ${DOMAIN}
openssl genrsa -out ${DOMAIN}/tls.key 2048

cat > ${DOMAIN}/csr.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = CN
ST = GD
L = SZ
O = zerchin
OU = zerchin
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
EOF
if [[ -n ${DOMAIN_EXT} ]]
then
    IFS=","
    DNS=(${DOMAIN})
    DNS+=(${DOMAIN_EXT})
    for i in ${!DNS[@]} 
    do
        echo DNS.${i} "=" ${DNS[$i]} >> ${DOMAIN}/csr.conf
    done
    echo DNS.
fi
if [[ -n ${IP} ]]
then
    IFS=","
    ip=(${IP})
    for i in ${!ip[@]} 
    do
        echo IP.${i} "=" ${ip[$i]} >> ${DOMAIN}/csr.conf
    done
    echo DNS.
fi
cat >> ${DOMAIN}/csr.conf << EOF

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF


# 
openssl req -new -key ${DOMAIN}/tls.key -out ${DOMAIN}/tls.csr -config ${DOMAIN}/csr.conf

#
openssl x509 -req -in ${DOMAIN}/tls.csr -CA cacerts.pem  -CAkey cakey.pem \
  -CAcreateserial -out ${DOMAIN}/tls.crt -days ${DATE} \
  -extensions v3_ext -extfile ${DOMAIN}/csr.conf


# verify tls
# openssl x509  -noout -text -in ${DOMAIN}/tls.crt
# verify CA
# openssl verify -CAfile cacerts.pem test1.zerchin.xyz/tls.crt
# verify server
# openssl s_client -connect test1.zerchin.xyz:443 -servername test1.zerchin.xyz
# openssl s_client -connect test1.zerchin.xyz:443 -servername test1.zerchin.xyz -CAfile server-ca.crt
