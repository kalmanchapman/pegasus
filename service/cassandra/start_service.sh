#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

cmd='/usr/local/cassandra/bin/cassandra'
# Start each cassandra node
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_cmd_on_node ${dns} ${cmd}
done

echo "Cassandra started!"
