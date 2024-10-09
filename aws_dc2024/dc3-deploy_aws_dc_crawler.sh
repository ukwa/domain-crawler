#!/bin/sh
ENVFILE=$1
SLEEP=30
DEBUG=


# functions ----------------
function test_env_file {
	# read environment file
	[[ ${DEBUG} ]] && echo -e "ENVFILE:\t [${ENVFILE}]"
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

# start DC crawler stack
echo "Starting DC crawler services"
docker stack deploy --compose-file=dc3-docker-compose.yaml --detach=true dc_crawl

echo -e "Pausing ${SLEEP} seconds whilst services initialise\n"
wait
sleep ${SLEEP}

docker service ls
echo
ps -ef | grep -v grep | grep heritrix

# ensure at least empty surts files exist
sudo touch ${HERITRIX_SURTS_PATH}/surts.txt
sudo touch ${HERITRIX_SURTS_PATH}/excluded-surts.txt
sudo chown ${HERITRIX_USER_ID} ${HERITRIX_SURTS_PATH}/*

echo -e "Completed -----------------------\n"
