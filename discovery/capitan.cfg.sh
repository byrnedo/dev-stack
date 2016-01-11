#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NET="sendify"

PREFIX="dev"


function getIfaceIP {
    local machine="$1"
    local iface="$2"
    docker-machine ssh "$machine" "ifconfig $iface | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'"
}


function populateXNodes(){
    local consul_ip="$(docker-machine ip swarm-consul)"
    local nodes="$*"

    for node in $nodes
    do

    local dockerBridgeIp=$(getIfaceIP $node docker0)
    local node_ip="$(docker-machine ip $node)"
    cat <<EOF

# Service Discovery - Consul
$node-consul image progrium/consul
$node-consul command -advertise $node_ip -join $consul_ip
$node-consul hostname ${PREFIX}_consul_$node
$node-consul publish ${node_ip}:8301:8301
$node-consul publish ${node_ip}:8301:8301/udp
$node-consul publish ${node_ip}:8302:8302
$node-consul publish ${node_ip}:8302:8302/udp
$node-consul publish ${node_ip}:8400:8400
$node-consul publish ${node_ip}:8500:8500
$node-consul publish ${dockerBridgeIp}:53:53
$node-consul publish ${dockerBridgeIp}:53:53/udp
$node-consul env constraint:node==$node
$node-consul hook after.run $DIR/../wait_for_net_port.sh 8500 30 sendify
$node-consul hook after.start $DIR/../wait_for_net_port.sh 8500 30 sendify
$node-consul net sendify

# Service Discovery - Registrator

$node-registrator image gliderlabs/registrator:master
$node-registrator command -retry-interval 1000 -retry-attempts 5 -internal consul://${consul_ip}:8500
$node-registrator hostname ${PREFIX}_registrator_$node
$node-registrator env constraint:node==$node
$node-registrator volume /var/run/docker.sock:/tmp/docker.sock

EOF
    done
}

populateXNodes swarm-master swarm-node-01
