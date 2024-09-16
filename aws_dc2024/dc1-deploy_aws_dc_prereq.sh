#!/bin/sh
ENVFILE=$1
SLEEP=10
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

# start DC kafka stack
echo "Starting DC kafka services"
docker stack deploy --compose-file=dc1-docker-compose.yaml --detach=true dc_prereq

echo -e "Pausing ${SLEEP} seconds whilst services initialise\n"
wait
sleep ${SLEEP}

docker service ls
