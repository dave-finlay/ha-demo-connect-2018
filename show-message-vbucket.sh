#!/bin/bash

install_dir=""
if [ -d ../install ]; then
    install_dir="../install"
elif [ -d install ]; then
    install_dir="install"
else
    echo "Couldn't not find Couchbase Server install dir"
    exit 1
fi

count=$1
if [ ! "${count}" ]; then
    count=1
fi

idx="0"
while [ $idx -lt $count ]; do
    if [ $idx -ne 0 ]; then
        sleep 1
    fi
    curl -s localhost:9000/pools/default/buckets/messages -u Administrator:asdasd | \
            ${install_dir}/bin/tools/vbuckettool - important-message;
    idx=$[ $idx + 1 ]
done