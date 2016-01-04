#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PREFIX=dev
cat <<EOF
#
# General redis container
#
redis image redis:latest
redis hostname ${PREFIX}_redis
redis publish 6379
redis hook after.run $DIR/wait_for_port.sh 6379
redis hook after.start $DIR/wait_for_port.sh 6379

#
# General mongodb container
#
mongo image mongo:latest
mongo command mongod --smallfiles
mongo hostname ${PREFIX}_mongo
mongo publish 27017
mongo hook after.run $DIR/wait_for_port.sh 27017
mongo hook after.start $DIR/wait_for_port.sh 27017

#
# General nats container
#
nats image nats:latest
nats hostname ${PREFIX}_nats
nats publish 4222
nats hook after.run $DIR/wait_for_port.sh 4222
nats hook after.start $DIR/wait_for_port.sh 4222
EOF
