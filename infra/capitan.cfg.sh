#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

net_arg=""
[ ! -z "$NET" ] && net_arg="net $NET"

cat <<EOF
#
# General redis container
#
redis image redis:latest
redis hostname redis
redis publish 6379
redis hook after.run $DIR/../wait_for_port.sh redis.service.consul 6379 30 $NET
redis hook after.start $DIR/../wait_for_port.sh redis.service.consul 6379 30 $NET
redis env constraint:role==infra
redis $net_arg

#
# General mongodb container
#
mongo image mongo:latest
mongo command mongod --smallfiles
mongo hostname mongo
mongo publish 27017
mongo hook after.run $DIR/../wait_for_port.sh mongo.service.consul 27017 30 $NET
mongo hook after.start $DIR/../wait_for_port.sh mongo.service.consul 27017 30 $NET
mongo env constraint:role==infra
mongo $net_arg

#
# General nats container
#
nats image nats:latest
nats hostname nats
nats publish 4222
nats hook after.run $DIR/../wait_for_port.sh nats-4222.service.consul 4222 30 $NET
nats hook after.start $DIR/../wait_for_port.sh nats-4222.service.consul 4222 30 $NET
nats env constraint:role==infra
nats $net_arg
EOF
