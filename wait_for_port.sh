#!/bin/bash

CONTAINER="$CAPITAN_CONTAINER_NAME"
PORT="$1"

HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)

count=0
echo "$(date) - trying to connect to ${HOST}:${PORT}"
while ! exec 6<>/dev/tcp/${HOST}/${PORT}; do
    count=$((count+1))
    echo "$(date) - attempt $count failed while trying to connect to ${HOST}:${PORT}"
    if [[ $count -gt 9 ]]
    then
        exec 6>&-
        exec 6<&-
        exit 1
    fi

    sleep 1
done

exec 6>&-
exec 6<&-
exit 0


