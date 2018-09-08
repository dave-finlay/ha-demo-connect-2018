#!/bin/bash

function drop_dir () {
    dir=$1
    if [ -f $dir ]; then
        echo "$dir is a file not a directory as expected; not dropping"
        exit 1
    elif [ -d $dir ]; then
        echo "Dropping $dir"
        rm -rf $dir
    else
        echo "$dir doesn't exist; nothing to drop"
    fi
}

ns_server_dir=""
if [ -d ../ns_server ]; then
    ns_server_dir="../ns_server"
elif [ -d ns_server ]; then
    ns_server_dir="ns_server"
else
    echo "Couldn't not find ns_server"
    exit 1
fi

drop_dir ${ns_server_dir}/data
drop_dir ${ns_server_dir}/logs
