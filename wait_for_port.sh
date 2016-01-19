#!/bin/bash


function checkPort(){
    local hostname=$1
    local portnum=$2
    
    docker run --rm --entrypoint /usr/bin/nc $NET joffotron/docker-net-tools -z "$hostname" "$portnum"
}

HOST="$1"
PORT="$2"
MAX_ATTEMPTS="${3:-10}"
NET="$4"

if [ -n "$NET" ]; then
    NET="--net $NET"
fi

count=1
echo -e "\e[32m$(date) - trying to connect to ${HOST}:${PORT}\e[39m"
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
        echo >&2
        echo -e "\e[31m$(date) - failed to connect after $count attempts, exitting..\e[39m" >&2
        exit 1
    fi

    count=$((count+1))

    sleep 1
done

echo
echo -e "\e[32m$(date) - attempt $count successfully connected\e[39m"
exit 0


