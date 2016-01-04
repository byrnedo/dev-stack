#!/bin/bash

CONTAINER="$CAPITAN_CONTAINER_NAME"
PORT="$1"
MAX_ATTEMPTS="${2:-10}"


HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)

count=1
echo "$(date) - trying to connect to ${HOST}:${PORT}"
while ! exec 6<>/dev/tcp/${HOST}/${PORT} 2>/dev/null; do
    ##echo "$(date) - attempt $count failed while trying to connect to ${HOST}:${PORT}"
    if [[ $count -ge $MAX_ATTEMPTS ]]
    then
        exec 6>&-
        exec 6<&-
        echo "$(date) - failed to connect after $count attempts, exitting.."
        exit 1
    fi

    count=$((count+1))

    sleep 1
done

echo "$(date) - attempt $count successfully connected"
exec 6>&-
exec 6<&-
exit 0


