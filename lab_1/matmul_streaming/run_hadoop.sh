SOURCE_BASE_PATH="/matmul_streaming"

INPUT_HADOOP_DIR="/matmul_streaming/input"
OUTPUT_HADOOP_DIR="/matmul_streaming/output"

HADOOP_STREAMING_PATH="${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar"

hdfs dfs -test -d ${INPUT_HADOOP_DIR}
if [ $? -eq 0 ];
  then
    echo "Remove ${INPUT_HADOOP_DIR}"
    hdfs dfs -rm -r ${INPUT_HADOOP_DIR}
fi

hdfs dfs -test -d ${OUTPUT_HADOOP_DIR}
if [ $? -eq 0 ];
  then
    echo "Remove ${OUTPUT_HADOOP_DIR}"
    hdfs dfs -rm -r ${OUTPUT_HADOOP_DIR}
fi

test -d ${SOURCE_BASE_PATH}/data/output
if [ $? -eq 0 ];
  then
    echo "Remove ${SOURCE_BASE_PATH}/data/output"
    rm -rf ${SOURCE_BASE_PATH}/data/output
fi

hdfs dfs -mkdir -p ${INPUT_HADOOP_DIR}
hdfs dfs -copyFromLocal ${SOURCE_BASE_PATH}/data/input ${INPUT_HADOOP_DIR}

chmod 0777 ${SOURCE_BASE_PATH}/src/mapper.py
chmod 0777 ${SOURCE_BASE_PATH}/src/reducer.py

hadoop_streaming_arguments="\
  -D mapred.map.tasks=${4} \
  -D mapred.reduce.tasks=${5} \
  -files ${SOURCE_BASE_PATH}/src  \
  -mapper src/mapper.py -reducer src/reducer.py \
  -input ${INPUT_HADOOP_DIR}/* -output ${OUTPUT_HADOOP_DIR} \
  -cmdenv number_of_rows_A=${1} \
  -cmdenv number_of_columns_B=${3} \
  -cmdenv number_of_columns_A/rows_B=${2} \
"

echo "Run streaming with arguments: \n${hadoop_streaming_arguments}"
hadoop jar ${HADOOP_STREAMING_PATH} ${hadoop_streaming_arguments}

hdfs dfs -copyToLocal ${OUTPUT_HADOOP_DIR} ${SOURCE_BASE_PATH}/data

hdfs dfs -rm -r ${INPUT_HADOOP_DIR}
hdfs dfs -rm -r ${OUTPUT_HADOOP_DIR}