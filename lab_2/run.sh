NAME="collaborative_filtering"

test -d ./data/output
if [ $? -eq 0 ];
  then
    echo "Remove ./data/output from host"
    rm -r ./data/output
fi

docker exec -it namenode test -d ./${NAME}
if [ $? -eq 0 ];
  then
    echo "Remove ./collaborative_filtration in docker"
    docker exec -it namenode rm -r /${NAME}
fi

# Copy all data and code to namenode (see also `docker cp`)
echo "Copying all data and code to namenode"
docker cp ../${NAME} namenode:/${NAME}
# Run Hadoop Streaming on namenode (see also `docker exec`)
echo "Running Hadoop Streaming on namenode"
docker exec -it namenode sh /${NAME}/run_hadoop.sh
# Copy results from namenode (see also `docker cp`)
echo "Copying results from namenode"
docker cp namenode:/${NAME}/data/output ./data/output