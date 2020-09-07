#!/bin/bash

REDOC_CLI=`command -v redoc-cli`

usage()
{
    echo -e "$(basename "$0") [-h] [-i <input>] [-o <output>] -- convert OpenAPI specification to HTML file

where:
    -h  show this help text
    -i  json or yaml file to convert to html page; defaults to openapi.yml
    -o  output target for the converted html page; defaults to index.html"
    exit
}

# START #

FATAL_EXIT=1

input="openapi.yml"
output="index.html"

while getopts "hi:o:" opt; do
    case "$opt" in
    [h?]) usage
        ;;
    i) input=$OPTARG
        ;;
    o) output=$OPTARG
        ;;
    esac
done

if [ ! -f "$input" ]; then
    echo "'$input': No such file or directory"
    exit $FATAL_EXIT
fi

dir=`cd "$(dirname $output)"; pwd`
if [ ${#dir} -gt 0 ] && [ ! -d "$dir" ]; then
    echo "'$dir': No such directory"
    exit $FATAL_EXIT
fi

mkdir -p /tmp/redoc-do/ && \
    $REDOC_CLI bundle ${input} -o ${output}
