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

# get directory of INFILE, check valid
inDir=$(dirname ${INFILE})
if ! [[ -d ${inDir}/ ]]; then
	echo "ERROR: Directory [{$inDir}] of input file [${INFILE}] missing"
	exit 1
fi

# get basename of INFILE
bnFile=$(basename ${INFILE})

echo "Submitting seeds into  ${KAFKA_BOOTSTRAP_SERVERS} dc.tocrawl  from  ${INFILE}"
# as the Nominet seeds list will take hours to submit, command is nohup'd
nohup docker run -v ${inDir}:/host --net=dc_kafka_default ${CRAWL_STREAM_IMAGE} submit -k ${KAFKA_BOOTSTRAP_SERVERS} -L now dc.tocrawl /host/${bnFile} &

exit 0
