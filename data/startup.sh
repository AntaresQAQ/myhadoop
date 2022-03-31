#!/bin/sh
service ssh start
if [ ! $NAMENODE_WORKER = '' ]; then
    $HADOOP_HOME/sbin/start-dfs.sh
fi
if [ ! $RESOURCES_MANAGER_WORKER = '' ]; then
    $HADOOP_HOME/sbin/start-yarn.sh
fi
bash