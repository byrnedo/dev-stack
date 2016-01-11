#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NET=sendify


PREFIX=dev
cat <<EOF
#
# General redis container
#
redis image redis:latest
redis hostname ${PREFIX}_redis
redis publish 6379
redis hook after.run $DIR/../wait_for_consul_port.sh redis.service.consul 6379 30 $NET
redis hook after.start $DIR/../wait_for_consul_port.sh redis.service.consul 6379 30 $NET
redis net $NET

#
# General mongodb container
#
mongo image mongo:latest
mongo command mongod --smallfiles
mongo hostname ${PREFIX}_mongo
mongo publish 27017
mongo hook after.run $DIR/../wait_for_consul_port.sh mongo.service.consul 27017 30 $NET
mongo hook after.start $DIR/../wait_for_consul_port.sh mongo.service.consul 27017 30 $NET
mongo net $NET

#
# General nats container
#
nats image nats:latest
nats hostname ${PREFIX}_nats
nats publish 4222
nats hook after.run $DIR/../wait_for_consul_port.sh nats-4222.service.consul 4222 30 $NET
nats hook after.start $DIR/../wait_for_consul_port.sh nats-4222.service.consul 4222 30 $NET
nats net $NET
EOF