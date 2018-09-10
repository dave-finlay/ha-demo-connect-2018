#!/bin/bash

node_idx=$1
if [ ! "${node_idx}" ]; then
    echo "Provide number of node to start"
    exit 1
fi

ns_server_dir=""
if [ -d ../ns_server ]; then
    ns_server_dir="../ns_server"
elif [ -d ns_server ]; then
    ns_server_dir="ns_server"
else
    echo "Could not find ns_server"
    exit 1
fi

# We set the number of vbuckets for the buckets in the cluster to be created to 64.
# This doesn't affect functional behavior, but makes the demo snappier.
export COUCHBASE_NUM_VBUCKETS=64

echo "Running node ${node_idx} ..."
cd ${ns_server_dir}

logs_dir=logs/n_${node_idx}
if [ ! -d $logs_dir ]; then
    mkdir -p $logs_dir
fi

./cluster_run --start-index ${node_idx} --nodes 1 --dont-rename \
              > ${logs_dir}/node_${node_idx}.log 2>&1
