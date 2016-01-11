#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PREFIX="dev"

cat <<EOF
# Service Discovery - Consul

#consul image progrium/consul
#consul command -server -bootstrap -node consul
#consul hostname ${PREFIX}_consul_1
#consul publish 8400:8400
#consul publish 127.0.0.1:8500:8500
#consul publish 172.17.42.1:8500:8500 
#consul publish 172.17.42.1:53:53/udp
#consul hook after.run $DIR/wait_for_port.sh 8500
#consul hook after.start $DIR/wait_for_port.sh 8500

# Service Discovery - Registrator

registrator image gliderlabs/registrator:master
registrator command -retry-interval 1000 -retry-attempts 5 -internal consul://192.168.99.100:8500
registrator hostname ${PREFIX}_registrator
registrator volume /var/run/docker.sock:/tmp/docker.sock
registrator net sendify
EOF
