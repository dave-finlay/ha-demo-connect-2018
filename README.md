# What This Repo is For 
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

Create the cluster. This will set up the server groups, add the nodes, create the bucket,
make sure the auto-failover settings are correct and rebalance:

```
create-cluster.sh
```

Open a couple of browser tabs and place them side-by-side:
```
open 'http://localhost:9000/ui/index.html#!/servers/list'
open 'http://localhost:9000/ui/index.html#!/buckets/analytics/ops?statsHostname=all&bucket=messages&openedStatsBlock=Server%20Resources&openedStatsBlock=Summary&zoom=minute'
```

Start the workload:
```
start-workload.sh
```

# Demo Steps

  1. Drop server 5. 
     Observe failover and effect on workload.
  2. Drop server 3
     Observe failover and effect on workload.
  3. Add back servers 3 and 5 via delta-node recovery. Rebalance
  4. Remove writability from node 5. Observe failover and workload. Add back. Rebalance.
  5. Hang the orchestrator. Observe failover and workload. Add back. Rebalance.
  6. Drop server group 3. Observe failover and workload. 

# Handy Commands You Might Need

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

List server groups:
```
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd  --list
```

Delete a server group:
```
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd  --group-name "Group 5" --delete
```


