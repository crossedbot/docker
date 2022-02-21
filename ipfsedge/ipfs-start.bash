#!/bin/bash

log()
{
    echo "$(date +"%F %T"): $*"
}

join_by()
{
    local d=$1; shift; # delimiter
    local f=$1; shift; # array
    printf %s "$f" "${@/#/$d}";
}

usage()
{
    echo -e "$(basename "$0") [-h] [-c] [-s] [-p <peer id>]... [-b <peer id>]... -- program to start an IPFS node

where:
    -h  show this help text
    -s  run as private swarm network
    -k  set private swarm key
    -c  set cluster secret and run the cluster service
    -p  add peer to the IPFS bootstrap list
    -b  add peer to the IPFS cluster bootstrap list; when running in cluster mode"
    exit
}

# START #

peers=()
cluster_peers=()
secret=""
run_as_swarm=false
key=""

while getopts "hsk:c:p:b:" opt; do
    case "$opt" in
    [h?]) usage
        ;;
    s)  run_as_swarm=true
        ;;
    k)  key="${OPTARG}"
        ;;
    c)  secret="${OPTARG}"
        ;;
    p)  peers+=($OPTARG)
        ;;
    b)  cluster_peers+=($OPTARG)
        ;;
    esac
done

# Start IPFS
ipfs init -e
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
ipfs bootstrap rm --all
if [ ${#peers[@]} -gt 0 ]; then
    ipfs bootstrap add ${peers[*]}
fi
if [ ${run_as_swarm} == true ]; then
    export LIBP2P_FORCE_PNET=1
fi
if [ -n "${key}" ]; then
    repo_path=`ipfs repo stat | grep RepoPath | awk -F' ' '{print $2}'`
    echo -n "${key}" > "${repo_path}/swarm.key"
fi
ipfs daemon > /var/log/ipfs.log 2>&1 &

# Start Cluster
if [ -n "${secret}" ]; then
    export CLUSTER_SECRET="${secret}"
    ipfs-cluster-service init
    sed -i -e 's|/ip4/127.0.0.1/tcp/9094|/ip4/0.0.0.0/tcp/9094|g' \
        /root/.ipfs-cluster/service.json
    params=()
    if [ ${#cluster_peers[@]} -gt 0 ]; then
        params+=("--bootstrap")
        params+=(`join_by , ${cluster_peers[@]}`)
    fi
    ipfs-cluster-service daemon ${params[@]} > /var/log/ipfs-cluster-service.log 2>&1 &
fi

# Wait And Exit
echo "IPFS running..."
wait
echo "IPFS stopped - exiting..."
