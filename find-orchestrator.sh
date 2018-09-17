#!/bin/bash

cmd="curl localhost:9001/diag/eval -d node(leader_registry:whereis_name(ns_orchestrator)) -u Administrator:asdasd"

echo "$cmd"
$cmd

printf "\n"

