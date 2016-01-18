#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[ -n "$NET" ] && net_arg="net $NET"

docker_bridge_ip=172.17.0.1
node_ip=0.0.0.0
consul_args="-advertise $node_ip -join $CONSUL_IP"


if [ "$ENVIRONMENT" == "dev" ] && [ "$SWARM_NODES" -eq 1 ]; then
    node_ip=$docker_bridge_ip
    consul_args="-server -advertise $node_ip -bootstrap -ui-dir /ui"
fi


cat <<EOF

# Service Discovery - Consul

consul-agent image progrium/consul
consul-agent command $consul_args
consul-agent hostname consul_agent
consul-agent publish ${node_ip}:8301:8301
consul-agent publish ${node_ip}:8301:8301/udp
consul-agent publish ${node_ip}:8302:8302
consul-agent publish ${node_ip}:8302:8302/udp
consul-agent publish ${node_ip}:8400:8400
consul-agent publish ${node_ip}:8500:8500
consul-agent publish ${docker_bridge_ip}:53:53
consul-agent publish ${docker_bridge_ip}:53:53/udp
# WILL ONLY RUN ON A NODE WHICH DOESN'T HAVE ONE ALREADY
consul-agent env affinity:container!=~*-consul-agent_*
consul-agent $net_arg
consul-agent scale $SWARM_NODES
EOF

if [ "$ENVIRONMENT" == "dev" ] && [ "$SWARM_NODES" -eq 1 ]; then
    echo "consul-agent hook after.run $DIR/../wait_for_port.sh ${node_ip} 8500 30 $NET"
    echo "consul-agent hook after.start $DIR/../wait_for_port.sh ${node_ip} 8500 30 $NET"
else
    echo "consul-agent hook after.run $DIR/../wait_for_port.sh \$CAPITAN_CONTAINER_NAME 8500 30 $NET"
    echo "consul-agent hook after.start $DIR/../wait_for_port.sh \$CAPITAN_CONTAINER_NAME 8500 30 $NET"
fi

cat <<EOF

# Service Discovery - Registrator

registrator image gliderlabs/registrator:master
registrator command -retry-interval 1000 -retry-attempts 5 -internal consul://${CONSUL_IP}:8500
registrator hostname registrator
# WILL ONLY RUN ON A NODE WHICH DOESN'T HAVE ONE ALREADY
registrator env affinity:container!=~*-registrator_*
registrator volume /var/run/docker.sock:/tmp/docker.sock
registrator scale $SWARM_NODES

EOF

