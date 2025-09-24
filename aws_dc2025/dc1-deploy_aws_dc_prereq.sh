#!/bin/sh
ENVFILE=$1
SLEEP=30
DEBUG=


# functions ----------------
function test_env_file {
	# read environment file
	[[ ${DEBUG} ]] && echo -e "ENVFILE:\t [${ENVFILE}]"
	if [[ "${ENVFILE}" == "" ]]; then
		echo "ERROR: You must give an argument that specifies the deployment, e.g. aws_dc2025_crawler08-prod.env"
		exit 1
	fi
	if ! [[ -f ${ENVFILE} ]]; then
		echo "ERROR: argument [${ENVFILE}] environment file missing"
		exit 1
	fi
	source ./${ENVFILE}
}


# script -------------------
# ensure docker running and swarm initialised
_t=$(systemctl is-active docker)
if ! [[ ${_t} == 'active' ]]; then
	echo "ERROR: docker not running [status '${_t}']"
	exit 1
fi
_t=''
_t=$(docker service ls 2>&1 >/dev/null)
echo -e "_t:\t [${_t}]"
if [[ ${_t} ]]; then
	echo "ERROR: docker swarm not initialised [status '${_t}']"
	exit 1
fi

test_env_file

# start DC kafka stack
echo "Starting DC kafka services"
docker stack deploy --compose-file=dc1-docker-compose.yaml --detach=true dc_kafka

echo -e "Pausing ${SLEEP} seconds whilst services initialise\n"
wait
sleep ${SLEEP}

docker service ls
echo -e "Completed -----------------------\n"
