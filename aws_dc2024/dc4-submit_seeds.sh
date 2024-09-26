#!/bin/env bash
#  For each URL in argument file, submit to crawler

# globals
ENVFILE=$1
INFILE=$2
DEBUG=

# functions ----------------
function test_file_arg {
	local f=$1
	[[ ${DEBUG} ]] && echo -e "f:\t [${f}]"
	if ! [[ -f ${f} ]]; then
		echo "ERROR: argument [${f}] input file missing"
		echo -e "Usage: $0 <.env file> <input seed list>\n"
		exit 1
	fi
}


# script -------------------
test_file_arg ${ENVFILE}
source ./${ENVFILE}
test_file_arg ${INFILE}

c=0
while read line; do
#	docker run --network=dc_kafka_default ${CRAWL_STREAM_IMAGE} submit -k kafka-1:9092 -S dc.tocrawl ${line}
	c=$(( c + 1 ))

done < <(cat ${INFILE})

echo "Submitted ${c} lines from ${INFILE}"
echo -e "Completed -----------------------\n"
