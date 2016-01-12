#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NET="sendify"
SCALE=2

consul_ip="$(docker-machine ip swarm-consul)"
docker_bridge_ip=172.17.0.1
node_ip=0.0.0.0

# Service Discovery - Consul
cat <<EOF
consul-agent image progrium/consul
consul-agent command -advertise $node_ip -join $consul_ip
consul-agent hostname consul_agent
consul-agent publish ${node_ip}:8301:8301
consul-agent publish ${node_ip}:8301:8301/udp
consul-agent publish ${node_ip}:8302:8302
consul-agent publish ${node_ip}:8302:8302/udp
consul-agent publish ${node_ip}:8400:8400
consul-agent publish ${node_ip}:8500:8500
consul-agent publish ${docker_bridge_ip}:53:53
consul-agent publish ${docker_bridge_ip}:53:53/udp
consul-agent env affinity:container!=~*-consul-agent_*
consul-agent hook after.run $DIR/../wait_for_port.sh \$CAPITAN_CONTAINER_NAME 8500 30 sendify
consul-agent hook after.start $DIR/../wait_for_port.sh \$CAPITAN_CONTAINER_NAME 8500 30 sendify
consul-agent scale $SCALE
consul-agent net sendify

# Service Discovery - Registrator

registrator image gliderlabs/registrator:master
registrator command -retry-interval 1000 -retry-attempts 5 -internal consul://${consul_ip}:8500
registrator hostname registrator
registrator env affinity:container!=~*-registrator_*
registrator volume /var/run/docker.sock:/tmp/docker.sock
registrator scale $SCALE

EOF

