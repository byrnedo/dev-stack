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
    local consul_ip="$(docker-machine ip swarm-node-01)"
    local nodes="$*"

    for node in $nodes
    do

    local dockerBridgeIp=$(getIfaceIP $node docker0)
    local node_ip="$(docker-machine ip $node)"
    cat <<EOF

# Service Discovery - Consul
consul-$node image progrium/consul
consul-$node command -server -advertise $node_ip -join $consul_ip
consul-$node hostname ${PREFIX}_consul_$node
consul-$node publish 8400:8400
consul-$node publish ${dockerBridgeIp}:8500:8500 
consul-$node publish ${dockerBridgeIp}:53:53/udp
consul-$node env constraint:node==$node
consul-$node hook after.run $DIR/wait_for_port.sh 8500 30 sendify
consul-$node hook after.start $DIR/wait_for_port.sh 8500 30 sendify
consul-$node net sendify

# Service Discovery - Registrator

registrator-$node image gliderlabs/registrator:master
registrator-$node command -retry-interval 1000 -retry-attempts 5 -internal consul://127.0.0.1:8500
registrator-$node hostname ${PREFIX}_registrator_$node
registrator-$node env constraint:node==$node
registrator-$node volume /var/run/docker.sock:/tmp/docker.sock

EOF
    done
}

populateXNodes swarm-master swarm-node-01
