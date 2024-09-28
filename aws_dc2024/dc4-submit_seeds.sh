#!/bin/env bash
#  For each URL in argument file, submit to crawler

# globals
ENVFILE=$1
INFILE=$2
LOGFILE=log.$(basename $0 .sh)
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
echo "Submitting seeds into   kafka-1:9092 dc.tocrawl  from  ${INFILE}" >> ${LOGFILE}

# initialise line/seed counter
c=0

{	# try
	while read line; do
		docker run --network=dc_kafka_default ${CRAWL_STREAM_IMAGE} submit -k kafka-1:9092 -S dc.tocrawl ${line}
		c=$(( c + 1 ))
		[[ ${c} =~ 00$ ]] && echo -e "$(date +'%Y-%m-%d %H.%M.%S')\t ${c} submitted" >> ${LOGFILE}
	done < <(cat ${INFILE})

	echo -e "$(date +'%Y-%m-%d %H.%M.%S')\t Submitted ${c} lines from ${INFILE}" >> ${LOGFILE}
	echo -e "Completed -----------------------\n" >> ${LOGFILE}

} || {	# catch
	echo -e "$(date +'%Y-%m-%d %H.%M.%S')\t Submitted ${c} lines from ${INFILE}" >> ${LOGFILE}
	echo -e "Stopping ------------------------\n" >> ${LOGFILE}
}

exit 0
