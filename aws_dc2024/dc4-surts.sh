#!/bin/sh
ENVFILE=$1
DEBUG=


# functions ----------------
function test_env_file {
	# read environment file
	if [[ "${ENVFILE}" == "" ]]; then
		echo "ERROR: You must give an argument that specifies the deployment, e.g. aws_dc2024_crawler08-prod.env"
		exit 1
	fi
	if ! [[ -f ${ENVFILE} ]]; then
		echo "ERROR: argument [${ENVFILE}] environment file missing"
		exit 1
	fi
	source ./${ENVFILE}
}


# script -------------------
test_env_file
cp -v ${LOCAL_SURTS_PATH}/*.txt ${HERITRIX_SURTS_PATH}/
echo
