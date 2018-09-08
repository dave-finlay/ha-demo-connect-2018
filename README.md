# What this repo is for 
This repo captures instructions for setting up a cluster_run based build 
for the HA demo for Connect SV 2018.

# Setup
First clone this repo and sync and build 5.5.1 Couchbase Server:
 
```
git clone git@github.com:dave-finlay/ha-demo-connect-2018.git
repo init -u git://github.com/couchbase/manifest -m released/5.5.1.xml -g all
repo sync
make -j4 EXTRA_CMAKE_OPTIONS='-DCOUCHBASE_DISABLED_UNIT_TESTS="kv_engine;platform"'
```

Change to the demo directory:
```
cd ha-demo-connect-2018
```

Start the cluster. Best to do so in 6 separate windows:

```
start-server.sh 0
start-server.sh 1
start-server.sh 2
start-server.sh 3
start-server.sh 4
start-server.sh 5
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
start-workload.sh
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
