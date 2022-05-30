SOURCE_BASE_PATH="/collaborative_filtering"

INPUT_HADOOP_DIR="/collaborative_filtering/input"
OUTPUT_HADOOP_DIR="/collaborative_filtering/output"

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
hdfs dfs -copyFromLocal ${SOURCE_BASE_PATH}/data/input/* ${INPUT_HADOOP_DIR}


chmod -R 0777 ${SOURCE_BASE_PATH}/src

#1
hadoop_streaming_arguments="\
  -D mapreduce.job.reduces=4 \
  -D stream.num.map.output.key.fields=1 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -files ${SOURCE_BASE_PATH}/src \
  -mapper src/mapper_1.py \
  -reducer src/reducer_1.py \
  -input ${INPUT_HADOOP_DIR}/ratings.csv \
  -output ${OUTPUT_HADOOP_DIR}/stage_1 \
"
echo "Running streaming (stage 1) with arguments: \n${hadoop_streaming_arguments}"
hadoop jar ${HADOOP_STREAMING_PATH} ${hadoop_streaming_arguments}

#2
hadoop_streaming_arguments="\
  -D mapreduce.job.reduces=4 \
  -D stream.num.map.output.key.fields=1 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -files ${SOURCE_BASE_PATH}/src \
  -mapper src/mapper_2.py \
  -reducer src/reducer_2.py \
  -input ${OUTPUT_HADOOP_DIR}/stage_1 \
  -output ${OUTPUT_HADOOP_DIR}/stage_2 \
"
echo "Running streaming (stage 2) with arguments: \n${hadoop_streaming_arguments}"
hadoop jar ${HADOOP_STREAMING_PATH} ${hadoop_streaming_arguments}

#3
hadoop_streaming_arguments="\
  -D mapreduce.job.reduces=4 \
  -D stream.num.map.output.key.fields=1 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -files ${SOURCE_BASE_PATH}/src \
  -mapper src/mapper_3.py \
  -reducer src/reducer_3.py \
  -input ${OUTPUT_HADOOP_DIR}/stage_2,${INPUT_HADOOP_DIR}/ratings.csv \
  -output ${OUTPUT_HADOOP_DIR}/stage_3 \
"
echo "Running streaming (stage 3) with arguments: \n${hadoop_streaming_arguments}"
hadoop jar ${HADOOP_STREAMING_PATH} ${hadoop_streaming_arguments}

#4
hadoop_streaming_arguments="\
  -D mapreduce.job.reduces=4 \
  -D mapreduce.job.reduce.slowstart.completedmaps=1 \
  -D stream.num.map.output.key.fields=2 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -D mapreduce.reduce.memory.mb=256 \
  -D mapreduce.reduce.java.opts=-Xmx192m \
  -files ${SOURCE_BASE_PATH}/src \
  -mapper src/mapper_4.py \
  -reducer src/reducer_4.py \
  -input ${OUTPUT_HADOOP_DIR}/stage_3 \
  -output ${OUTPUT_HADOOP_DIR}/stage_4 \
"
echo "Running streaming (stage 4) with arguments: \n${hadoop_streaming_arguments}"
hadoop jar ${HADOOP_STREAMING_PATH} ${hadoop_streaming_arguments}

#5
echo "Running streaming (stage 5) with arguments: \n
  -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
  -D stream.num.map.output.key.fields=3 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -D mapreduce.map.output.key.field.separator=@ \
  -D mapreduce.partition.keypartitioner.options=-k1,1n \
  -D mapreduce.partition.keycomparator.options="-k1,1n -k3,3nr -k2,2" \
  -D mapreduce.map.memory.mb=256 \
  -D mapreduce.map.java.opts=-Xmx192m \
  -D mapreduce.reduce.memory.mb=256 \
  -D mapreduce.reduce.java.opts=-Xmx192m \
  -files ${SOURCE_BASE_PATH}/src,${SOURCE_BASE_PATH}/data/input/movies.csv \
  -mapper src/mapper_5.py \
  -reducer src/reducer_5.py \
  -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
  -input ${OUTPUT_HADOOP_DIR}/stage_4 \
  -output ${OUTPUT_HADOOP_DIR}/final \
"
hadoop jar ${HADOOP_STREAMING_PATH} \
  -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
  -D stream.num.map.output.key.fields=3 \
  -D stream.map.output.field.separator=@ \
  -D stream.reduce.input.field.separator=@ \
  -D mapreduce.map.output.key.field.separator=@ \
  -D mapreduce.partition.keypartitioner.options=-k1,1n \
  -D mapreduce.partition.keycomparator.options="-k1,1n -k3,3nr -k2,2" \
  -D mapreduce.map.memory.mb=256 \
  -D mapreduce.map.java.opts=-Xmx192m \
  -D mapreduce.reduce.memory.mb=256 \
  -D mapreduce.reduce.java.opts=-Xmx192m \
  -files ${SOURCE_BASE_PATH}/src,${SOURCE_BASE_PATH}/data/input/movies.csv \
  -mapper src/mapper_5.py \
  -reducer src/reducer_5.py \
  -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
  -input ${OUTPUT_HADOOP_DIR}/stage_4 \
  -output ${OUTPUT_HADOOP_DIR}/final \

hdfs dfs -copyToLocal ${OUTPUT_HADOOP_DIR} ${SOURCE_BASE_PATH}/data

hdfs dfs -rm -r ${INPUT_HADOOP_DIR}
hdfs dfs -rm -r ${OUTPUT_HADOOP_DIR}