#!/bin/bash

ns_server_dir=""
if [ -d ../ns_server ]; then
    ns_server_dir="../ns_server"
elif [ -d ns_server ]; then
    ns_server_dir="ns_server"
else
    echo "Could not find ns_server"
    exit 1
fi

node=$1
if [ ! "${node}" ]; then
    echo "Must specify node"
    exit 1
fi

mode=$2
if [ ! "${mode}" ]; then
    echo "Must specify mode"
    exit 1
fi

cmd="chmod -R ugo${mode} ../ns_server/data/n_${node}/data"
echo "Running: $cmd"
$cmd