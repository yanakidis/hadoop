# Task dimension
N=${1}
M=${2}
K=${3}
# Number of mappers
N_M=${4}
# Number of reducers
N_R=${5}

test -d ./data/output
if [ $? -eq 0 ];
  then
    echo "Remove ./data/output from host"
    rm -rf ./data/output
fi

docker exec -it namenode test -d ./matmul_streaming
if [ $? -eq 0 ];
  then
    echo "Remove ./matmul_streaming in docker"
    docker exec -it namenode rm -rf /matmul_streaming
fi

# Generate data for matrix multiplication task
echo "Generating data for matrix multiplication task"
python3 generate_task.py -n ${N} -m ${M} -k ${K}


# Copy all data and code to namenode (see also `docker cp`)
echo "Copying all data and code to namenode"
docker cp ../matmul_streaming namenode:/matmul_streaming
# Run Hadoop Streaming on namenode (see also `docker exec`)
echo "Running Hadoop Streaming on namenode"
docker exec -it namenode sh /matmul_streaming/run_hadoop.sh ${N} ${M} ${K} ${N_M} ${N_R}
# Copy results from namenode (see also `docker cp`)
echo "Copying results from namenode"
docker cp namenode:/matmul_streaming/data/output ./data/output

# Check solution
echo "Checking solution..."
python3 check_answer.py -n ${N} -m ${M} -k ${K}