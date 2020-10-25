#!/bin/bash

FATAL_EXIT=1
BASE_DIR=/tmp
BUILD_DIR=`mktemp -d`

MD2PDF_CLI=`command -v md2pdf`
PDFTK_CLI=`command -v pdftk`

log()
{
    echo "$(date +"%F %T"): $*"
}

usage()
{
    echo -e "$(basename "$0") [-h] [-o <output>] <input pdf>... -- program to start a md2pdf node

where:
    -h  show this help text
    -o  output target for the converted PDF; defaults to output.pdf" 
    exit
}

# START #

arg_index=1 # start at 1 for the basename
output="output.pdf"

while getopts "ho:" opt; do
    case "$opt" in
    [h?]) usage
        ;;
    o) output=$OPTARG
        arg_index=$((arg_index+2)) # add 2 for flag and argument
        ;;
    esac
done

input=${@:$arg_index}
md_args=()
pdf_args=()

for i in ${input}
do
    if [ ! -f "$i" ]; then
        echo "'${input}': No such file or directory" >&2
        exit $FATAL_EXIT
    fi
    filename=`basename -- "$i"`
    md_args+=(${BUILD_DIR}/${filename})
    pdf_args+=(${BUILD_DIR}/${filename%.*}.pdf)
done

dir=`cd "$(dirname $output)"; pwd`
if [ ${#dir} -gt 0 ] && [ ! -d "$dir" ]; then
    echo "'${dir}': No such directory" >&2
    exit $FATAL_EXIT
fi

mkdir -p $BUILD_DIR && \
cp ${input[@]} $BUILD_DIR && \
$MD2PDF_CLI ${md_args[@]} \
    --basedir $BASE_DIR \
    --launch-options '{ "args": ["--no-sandbox"] }' && \
$PDFTK_CLI ${pdf_args[@]} output $output
