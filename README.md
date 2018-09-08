# What this repo is for 
This repo captures instructions for setting up a cluster_run based build 
for the HA demo for Connect SV 2018.

# Setup
First build 5.5.1 Couchbase Server:
 
```
repo init -u git://github.com/couchbase/manifest -m released/5.5.1.xml -g all
repo sync
```

Set the number of vbuckets for the buckets in the cluster to be created to 64.
This doesn't affect functional behavior, but makes the demo snappier.
```
export COUCHBASE_NUM_VBUCKETS=64
```

Start the cluster. Best to do so in 5 separate windows:

```
cluster_run --nodes 2 --dont-rename
cluster_run --start-index 2 --nodes 1 --dont-rename 
cluster_run --start-index 3 --nodes 1 --dont-rename 
cluster_run --start-index 4 --nodes 1 --dont-rename 
cluster_run --start-index 5 --nodes 1 --dont-rename 
```

Create the cluster and the server groups:

```
../couchbase-cli/couchbase-cli cluster-init -c 127.0.0.1:9000 \
              --cluster-username Administrator \
              --cluster-password asdasd \
              --cluster-ramsize 1024 \
              --cluster-name "Connect SV 2018 Demo" \
              --services data
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --group-name "Group 2" --create
../couchbase-cli/couchbase-cli group-manage -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --group-name "Group 3" --create
```

Add the nodes:
```
../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --server-add 127.0.0.1:9001 \
              --server-add-username Administrator --server-add-password asdasd \
              --group-name "Group 1" --services data
../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --server-add 127.0.0.1:9002 \
              --server-add-username Administrator --server-add-password asdasd \
              --group-name "Group 2" --services data
../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --server-add 127.0.0.1:9003 \
              --server-add-username Administrator --server-add-password asdasd \
              --group-name "Group 2" --services data
../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --server-add 127.0.0.1:9004 \
              --server-add-username Administrator --server-add-password asdasd \
              --group-name "Group 3" --services data
../couchbase-cli/couchbase-cli server-add -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --server-add 127.0.0.1:9005 \
              --server-add-username Administrator --server-add-password asdasd \
              --group-name "Group 3" --services data
```

And create the bucket:
```
../couchbase-cli/couchbase-cli bucket-create -c 127.0.0.1:9000 -u Administrator -p asdasd \
              --bucket messages \
              --bucket-type couchbase \
              --bucket-ramsize 1024 \
              --bucket-replica 2 \
              --wait
```

Rebalance:

```
../couchbase-cli/couchbase-cli rebalance -c 127.0.0.1:9000 -u Administrator -p asdasd 
```


