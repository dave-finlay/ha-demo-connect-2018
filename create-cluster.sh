#!/bin/bash -e

install_dir=""
if [ -d ../install ]; then
    install_dir="../install"
elif [ -d install ]; then
    install_dir="install"
else
    echo "Could not find Couchbase Server install dir"
    exit 1
fi

echo "Create initial cluster ..."
${install_dir}/bin/couchbase-cli cluster-init -c 127.0.0.1:9000 \
              --cluster-username Administrator \
              --cluster-password asdasd \
              --cluster-ramsize 1024 \
              --cluster-name "Connect SV 2018 Demo" \
              --services data

echo "Create server groups ..."
for g in `seq 2 3`
    do ${install_dir}/bin/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --group-name "Group $g" --create
done

echo "Add nodes ..."
for x in `seq 1 5`
    do ${install_dir}/bin/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
                 --server-add 127.0.0.1:900${x} \
                 --server-add-username Administrator --server-add-password asdasd \
                 --group-name "Group $((($x / 2) + 1))" --services data
done

echo "Create messages bucket ..."
${install_dir}/bin/couchbase-cli bucket-create -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --bucket messages \
              --bucket-type couchbase \
              --bucket-ramsize 1024 \
              --bucket-replica 2 \
              --enable-flush 1 \
              --wait

echo "Set up auto-failover settings ..."
${install_dir}/bin/couchbase-cli setting-autofailover -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --enable-auto-failover 1 \
              --auto-failover-timeout 5 \
              --enable-failover-of-server-groups 1 \
              --max-failovers 3 \
              --enable-failover-on-data-disk-issues 1 \
              --failover-data-disk-period 5

echo "Rebalance ..."
${install_dir}/bin/couchbase-cli rebalance -c 127.0.0.1:9000 -u Administrator -p asdasd
