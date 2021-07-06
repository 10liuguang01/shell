#!/bin/bash

#### 生成证书

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Guangdong/L=Shenzhen/O=Sangfor/OU=Personal/CN=registry.ai.sangfor.com" \
 -key ca.key \
 -out ca.crt
 
 
openssl genrsa -out registry.ai.sangfor.com.key 4096

openssl req -sha512 -new \
-subj "/C=CN/ST=Guangdong/L=Shenzhen/O=Sangfor/OU=Personal/CN=registry.ai.sangfor.com" \
-key registry.ai.sangfor.com.key \
-out registry.ai.sangfor.com.csr

    
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=registry.ai.sangfor.com
DNS.2=registry.ai.sangfor
DNS.3=harbor-1.novalocal
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in registry.ai.sangfor.com.csr \
    -out registry.ai.sangfor.com.crt
    
openssl x509 -inform PEM -in registry.ai.sangfor.com.crt -out registry.ai.sangfor.com.cert
