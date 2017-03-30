#!/bin/bash

function print_usage() {
    local cmdname=`basename "$0"`
    echo 
    echo "Usage:"
    echo "    $cmdname Domain HttpsPort HttpPort [IP]"
    echo " "
}
if [ "$1" = "--help" ]; then
	print_usage
    exit 0
fi

CaDir="ca"
ConfigFile="/sf/registry/etc/harbor.cfg"
DockerComposeFile="./docker-compose.yml"

# 获取域名、IP、端口
SignDomain=$1
HTTSPORT=$2
HTTPORT=$3
IP=$4
# HTTSPORT=$( echo ${SignDomain} | cut -d ":" -f 2 )
# SignDomain=$( echo ${SignDomain} | cut -d ":" -f 1 )
# IP=$( echo ${IP} | cut -d ":" -f 1 )
# if [ "x"${SignDomain} = "x"${HTTSPORT} ]; then
# 	HTTSPORT="443"
# fi

if [ $# -lt 3 ]; then
	print_usage
	exit 1
fi

./prepare

# 生成证书
pushd ./${CaDir}
	./gen.sh ${SignDomain} ${IP}
	# cp ${SignDomain}/"${SignDomain}.crt"  ${SignDomain}/"${SignDomain}.key" ../common/config/nginx/cert/
    sed -i 's#^ssl_cert =.*#ssl_cert = ./ca/'${SignDomain}/${SignDomain}.crt'#' ${ConfigFile}
    sed -i 's#^ssl_cert_key =.*#ssl_cert_key = ./ca/'${SignDomain}/${SignDomain}.key'#' ${ConfigFile}
popd

# 修改nginx配置
sed -i 's/registry\.me/'${SignDomain}'/g' ./common/config/nginx/nginx.conf

# harbor.cfg
if [ ${HTTSPORT} == "443" ]; then
    if [ "$IP"x != ""x ]; then
        sed -i 's/^hostname = .*$/hostname = '${IP}'/g' ${ConfigFile}
    else
        sed -i 's/^hostname = .*$/hostname = '${SignDomain}'/g' ${ConfigFile}
    fi
    
else
    if [ "$IP"x != ""x ]; then
        sed -i 's/^hostname = .*$/hostname = '${IP}':'${HTTSPORT}'/g' ${ConfigFile}
    else
        sed -i 's/^hostname = .*$/hostname = '${SignDomain}':'${HTTSPORT}'/g' ${ConfigFile}
    fi
fi

# docker-compose.yml
sed -i 's/80:80/'${HTTPORT}':80/g' ${DockerComposeFile}
sed -i 's/443:443/'${HTTSPORT}':443/g' ${DockerComposeFile}
