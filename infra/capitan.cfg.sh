#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

net_arg=""
[ ! -z "$NET" ] && net_arg="net $NET"

cat <<EOF
#
# General redis container
#
redis image redis:latest
redis hostname \$CAPITAN_CONTAINER_NAME
redis publish 6379
redis hook after.run $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.redis.service.consul 6379 30 $NET
redis hook after.start $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.redis.service.consul 6379 30 $NET
redis env constraint:role==infra
redis env SERVICE_TAGS=\$CAPITAN_CONTAINER_NAME
redis $net_arg

#
# General mongodb container
#
mongo image mongo:latest
mongo command mongod --smallfiles
mongo hostname \$CAPITAN_CONTAINER_NAME
mongo publish 27017
mongo hook after.run $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.mongo.service.consul 27017 30 $NET
mongo hook after.start $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.mongo.service.consul 27017 30 $NET
mongo env constraint:role==infra
mongo env SERVICE_TAGS=\$CAPITAN_CONTAINER_NAME
mongo $net_arg

#
# General nats container
#
nats image nats:latest
nats hostname \$CAPITAN_CONTAINER_NAME
nats publish 4222
nats hook after.run $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.nats-4222.service.consul 4222 30 $NET
nats hook after.start $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.nats-4222.service.consul 4222 30 $NET
nats env constraint:role==infra
nats env SERVICE_TAGS=\$CAPITAN_CONTAINER_NAME
nats $net_arg

# 
# General Mysql container
#
mysql image mysql:latest
mysql hostname \$CAPITAN_CONTAINER_NAME
mysql publish 3306
mysql hook after.run $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.mysql.service.consul 3306 30 $NET
mysql hook after.start $DIR/../wait_for_port.sh \${CAPITAN_CONTAINER_NAME}.mysql.service.consul 3306 30 $NET
mysql env constraint:role==infra
mysql env MYSQL_ROOT_PASSWORD=toor
mysql env SERVICE_TAGS=\$CAPITAN_CONTAINER_NAME
mysql $net_arg
EOF
