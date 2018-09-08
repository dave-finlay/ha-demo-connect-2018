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
    echo "Couldn't not find ns_server"
    exit 1
fi

echo "Running node ${node_idx} ..."
cd ${ns_server_dir}
./cluster_run --start-index ${node_idx} --nodes 1 --dont-rename \
              > logs/n_${node_idx}/node_${node_idx}.log 2>&1
