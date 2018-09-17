#!/bin/bash -e

node=$1
if [ ! "${node}" ]; then
    echo "Must specify node"
    exit 1
fi

signal=$2
if [ ! "${signal}" ]; then
    echo "Must specify signal"
    exit 1
fi

echo "Sending SIG_${signal} to node: n_${node}"
echo "OPID=\`pgrep -lf beam.smp | grep \"run child_erlang.*ns_bootstrap .*n_$node\" | cut -d \" \" -f 1\`; kill -${signal} \$OPID"
OPID=`pgrep -lf beam.smp | grep "run child_erlang.*ns_bootstrap .*n_$node" | cut -d " " -f 1`; kill -${signal} $OPID
