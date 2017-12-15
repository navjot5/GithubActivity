#/bin/bash

function killitif {
     docker ps -a  > /tmp/yy_xx$$
     if grep --quiet $1 /tmp/yy_xx$$
      then
      echo "killing older version of $1"
      docker rm -f `docker ps -a | grep $1  | sed -e 's: .*$::'`
    fi
}

# if argument is activity 2 then..
if [ "$1" = "activity2" ]
then
    NAME=web2
    SWAP=swap2
    KILL=web1

#else if activity
elif [ "$1" = "activity" ]
then
    NAME=web1
    SWAP=swap1
    KILL=web2

#if none 
else
    NAME=$1
    KILL=$(docker ps -a -f "name=web" | grep -oh "\w*web\w")
fi

# We kill the new container (if it already existed)
killitif $NAME

# Run the new container we want to swap to
echo "running new $1"
docker run -d -P --network ecs189_default --name $NAME $1

# Run the matching swap shell script
sleep 3 && docker exec ecs189_proxy_1 /bin/bash /bin/$SWAP.sh

# Kill the old container
killitif $KILL

# Clean up all other exited process
EXITED=$(docker ps -qa --no-trunc --filter "status=exited")
if [ ! -z "$EXITED" ]
then
    docker rm $EXITED
fi