#!/bin/bash

function print_usage() {
    local cmdname=`basename "$0"`
    echo 
    echo "Usage:"
    echo "    $cmdname domain IP"
    echo " "
}
if [ "$1" = "--help" ]; then
	print_usage
    exit 0
fi

signdomain=${1:-registry.me}
IP=$2

rm -rf ${signdomain} && mkdir ${signdomain} && cd ${signdomain} 

# # 创建CA证书
# openssl req \
# -subj "/C=CN/ST=Guangdong/CN=Sangfor Registry/O=Sangfor" \
# -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
# -x509 -days 3650 -out ca.crt

# 生成证书请求
openssl req \
-subj "/C=CN/ST=Guangdong/CN=${signdomain}/O=Sangfor" \
-newkey rsa:4096 -nodes -sha256 -keyout ${signdomain}.key \
-days 3650 \
-out ${signdomain}.csr

mkdir -p demoCA && cd demoCA && touch index.txt && echo `date +%s` > serial && cd ..

# 设置IP
if [ "$IP"x = ""x ]; then
  openssl ca -batch -in ${signdomain}.csr -out ${signdomain}.crt -cert ../ca.crt -keyfile ../ca.key \
  -days 3650 \
  -outdir .
else 
  echo subjectAltName = IP:${IP} > extfile.cnf
  # 为网站生成证书
  openssl ca -batch -in ${signdomain}.csr -out ${signdomain}.crt -cert ../ca.crt -keyfile ../ca.key \
  -extfile extfile.cnf \
  -days 3650 \
  -outdir .
fi

cd ..
