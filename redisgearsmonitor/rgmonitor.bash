#!/bin/bash

NODE=`command -v node`

usage()
{
    echo -e "$(basename "$0") [-h] [-l <host>] [-p <port>] [-s <password>] -- start RedisGears monitor
where:
    -h  show this help text
    -l  host address of the RedisGears instance; defaults to localhost
    -p  port of the RedisGears instance; defaults to 6379
    -s  password to the RedisGears instance"
    exit
}

# START #

FATAL_EXIT=1

args=()

while getopts "hl:p:s:" opt; do
    case "$opt" in
        [h?]) usage
            ;;
        l) args+=("--host" $OPTARG)
            ;;
        p)  args+=("--port" $OPTARG)
            ;;
        s)  args+=("--password" $OPTARG)
            ;;
    esac    
done

${NODE} /var/opt/RedisGearsMonitor/main.js ${args[@]}