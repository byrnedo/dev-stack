#!/bin/bash

CONTAINER="$1"
PORT="$2"
MAX_ATTEMPTS="${3:-10}"
NET="$4"
if [ -n "$NET" ]
then
    NET="--net $NET"
fi

function getHost(){
    echo $CONTAINER
}

function checkPort(){
    local host=$1
    local port=$2
    
    docker run --rm --entrypoint /usr/bin/nc $NET joffotron/docker-net-tools -w 1 $host $port
}


HOST=$(getHost)
count=1
echo "$(date) - trying to connect to ${HOST}:${PORT}"
while true;  do
    checkPort $HOST $PORT
        
    if [ $? -eq 0 ]
    then
        break
    fi
    echo -n "."
    ##echo "$(date) - attempt $count failed while trying to connect to ${HOST}:${PORT}"
    if [[ $count -ge $MAX_ATTEMPTS ]]
    then
        echo "$(date) - failed to connect after $count attempts, exitting.."
        exit 1
    fi

    count=$((count+1))

    sleep 1
done

echo "$(date) - attempt $count successfully connected"
exit 0


