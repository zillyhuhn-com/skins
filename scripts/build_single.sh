#!/bin/bash

error_code=0
source_file=.
target_file=.
res_width=1920
res_height=1080

if ! command -v inkscape &> /dev/null
then
    echo "inkscape could not be found, please install it to continue"
    exit
fi

if [[ -z ${1+x} || $1 -lt 1920 ]]; then
	error_code=$((1 | $error_code))
fi

if [[ -z ${2+x} || $2 -lt 1080 ]]; then
	error_code=$((2 | $error_code))
fi

if [[ -z ${3+x} ]]; then
	error_code=$((3 | $error_code))
fi

if [[ -z ${4+x} ]]; then
	error_code=$((4 | $error_code))
fi

if [[ $error_code != 0 ]]; then
	if [[ $(($error_code&1)) -ne 0 ]]; then
		echo "target resolution width not found or less than 1920"
	fi
	if [[ $(($error_code&2)) -ne 0 ]]; then
		echo "target resolution height not found or less than 1080"
	fi
	echo "usage: build_single.sh <target_resolution_width> <target_resolution_height> <svg_file> <target_png_file>"
	exit
fi

res_width=$1
res_height=$2
source_file=$3
target_file=$4

export LC_NUMERIC="en_US.UTF-8"
source_w=$(printf "%.0f\n" $(echo $(echo "$(grep -Eiwzo "<svg[^>]*>" $source_file | tr '\0' '\n')" | grep -Eo "width=\"([0-9.]|px)*\"") | grep -Eo "[0-9.]*"))
source_h=$(printf "%.0f\n" $(echo $(echo "$(grep -Eiwzo "<svg[^>]*>" $source_file | tr '\0' '\n')" | grep -Eo "height=\"([0-9.]|px)*\"") | grep -Eo "[0-9.]*"))

# expected size if the game runs at full HD
exp_w=$source_w
exp_h=$source_h

target_ratio=$(( ((($res_width + 1919) / 1920) > (($res_height + 1079) / 1080)) ? (($res_width + 1919) / 1920) : (($res_height + 1079) / 1080) ))
target_w=$(($exp_w * $target_ratio))
target_h=$(($exp_h * $target_ratio))

echo "exporting '${source_file}' to '${target_file}' at ${target_w}x${target_h}"
inkscape $source_file -C -w $target_w -h $target_h -o $target_file > /dev/null 2>&1
