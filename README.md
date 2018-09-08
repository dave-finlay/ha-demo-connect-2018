# What this repo is for 
This repo captures instructions for setting up a cluster_run based build 
for the HA demo for Connect SV 2018.

# Setup
First build 5.5.1 Couchbase Server:
 
```
repo init -u git://github.com/couchbase/manifest -m released/5.5.1.xml -g all
repo sync
make -j4 EXTRA_CMAKE_OPTIONS='-DCOUCHBASE_DISABLED_UNIT_TESTS="kv_engine;platform"'
```

Set the number of vbuckets for the buckets in the cluster to be created to 64.
This doesn't affect functional behavior, but makes the demo snappier.
```
export COUCHBASE_NUM_VBUCKETS=64
```

Start the cluster. Best to do so in 5 separate windows:

```
./cluster_run --nodes 2 --dont-rename
./cluster_run --start-index 2 --nodes 1 --dont-rename 
./cluster_run --start-index 3 --nodes 1 --dont-rename 
./cluster_run --start-index 4 --nodes 1 --dont-rename 
./cluster_run --start-index 5 --nodes 1 --dont-rename 
```

Create the cluster:

```
../couchbase-cli/couchbase-cli cluster-init -c 127.0.0.1:9000 \
              --cluster-username Administrator \
              --cluster-password asdasd \
              --cluster-ramsize 1024 \
              --cluster-name "Connect SV 2018 Demo" \
              --services data
```

List server groups:
```
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd  --list
```

Delete a server group:
```
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd  --group-name "Group 5" --delete
```

Create the server groups:
```
for g in `seq 2 3`
    do ../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --group-name "Group $g" --create
done
```

Add the nodes:
```
for x in `seq 1 5`
    do ../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
                 --server-add 127.0.0.1:900${x} \
                 --server-add-username Administrator --server-add-password asdasd \
                 --group-name "Group $((($x / 2) + 1))" --services data
done
```

And create the bucket:
```
../couchbase-cli/couchbase-cli bucket-create -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --bucket messages \
              --bucket-type couchbase \
              --bucket-ramsize 1024 \
              --bucket-replica 2 \
              --enable-flush 1 \
              --wait
```

Rebalance:

```
../couchbase-cli/couchbase-cli rebalance -c 127.0.0.1:9000 -u Administrator -p asdasd 
```

Configure the auto-failover settings:
```
../couchbase-cli/couchbase-cli setting-autofailover -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --enable-auto-failover 1 \
              --auto-failover-timeout 5 \
              --enable-failover-of-server-groups 1 \
              --max-failovers 3 \
              --enable-failover-on-data-disk-issues 1 \
              --failover-data-disk-period 5
```

Start the workload:
```
../install/bin/cbc-pillowfight  --rate-limit 1000 --json --username Administrator --password asdasd \
              --spec couchbase://localhost:12000/messages --no-population \
              -t 10 -B 1 -Dtimeout=0.001 
```


Disable and then re-enable writability of data on node 5:
```
chmod -R ugo-w ../ns_server/data/n_5/data
chmod -R ugo+w ../ns_server/data/n_5/data
```

Find the orchestrator:
```
curl localhost:9001/diag/eval -d 'node(leader_registry:whereis_name(ns_orchestrator)).' -u Administrator:asdasd
```

Pause / restart the orchestrator:

```
pgrep -lf beam.smp | \
              grep "run child_erlang child_start ns_bootstrap .*n_0" | \ 
              cut -d " " -f 1
kill -STOP $PID
kill -CONT $PID
```
