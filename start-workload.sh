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

${install_dir}/bin/cbc-pillowfight --rate-limit 1000 --json \
              --username Administrator --password asdasd \
              --spec couchbase://localhost:12000/messages --no-population \
              -t 10 -B 1 -Dtimeout=0.001
