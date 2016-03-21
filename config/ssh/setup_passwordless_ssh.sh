#!/bin/bash

# must be called from top level

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)
SLAVE_DNS=($(get_public_dns_with_name_and_role ${CLUSTER_NAME} worker))
MASTER_NAME=$(get_hostnames_with_name_and_role ${CLUSTER_NAME} master)
SLAVE_NAME=($(get_hostnames_with_name_and_role ${CLUSTER_NAME} worker))

# Enable passwordless SSH from local to master
if ! [ -f ~/.ssh/id_rsa ]; then
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi
cat ~/.ssh/id_rsa.pub | run_cmd_on_node ${MASTER_DNS} 'cat >> ~/.ssh/authorized_keys'

# Enable passwordless SSH from master to slaves
SCRIPT=${PEG_ROOT}/config/ssh/setup_ssh.sh
ARGS="${SLAVE_DNS[@]}"
run_script_on_node ${MASTER_DNS} ${SCRIPT} "${ARGS}"

# Add NameNode, DataNodes, and Secondary NameNode to known hosts
SCRIPT=${PEG_ROOT}/config/ssh/add_to_known_hosts.sh
ARGS="$MASTER_DNS $MASTER_NAME "${SLAVE_NAME[@]}""
run_script_on_node ${MASTER_DNS} ${SCRIPT} "${ARGS}"

