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

function test_storage_path {
	# check STORAGE_PATH exists
	if !  [[ -d ${STORAGE_PATH} ]]; then
		echo "ERROR: STORAGE_PATH [${STORAGE_PATH}] defined in [${ENVFILE}] missing"
		exit 1
	fi
}

function check_repos_exist {
	if ! [[ -d ${DC_CONFIG_PATH}/ ]]; then
		echo "ERROR: DC_CONFIG_PATH [${DC_CONFIG_PATH}] missing"
		exit 1
	else
		echo "Config directory ${DC_CONFIG_PATH} exists"
	fi

	if ! [[ -d ${DC_SEEDS_PATH}/ ]]; then
		echo "ERROR: DC_SEEDS_PATH [${DC_SEEDS_PATH}] missing"
		exit 1
	else
		echo "Seeds directory ${DC_SEEDS_PATH} exists"
	fi
}

function install_docker_compose {
	# See https://docs.docker.com/compose/install/standalone/ for details, including up to date version
	if ! [[ -f /usr/local/bin/docker-compose ]]; then
		sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
		sudo chown ${USER}:${USER} /usr/local/bin/docker-compose
		sudo chmod 750 /usr/local/bin/docker-compose
		ls -l /usr/local/bin/docker-compose
	fi
}

function make_directory {
	local _d=$1
	if [[ "${_d}" == "" ]]; then
		echo "ERROR: No directory defined - probably not set in ${ENVFILE}"
		exit 1
	fi
	if ! [[ -d ${_d} ]]; then
		echo -e "Making dir\t ${_d}"
		mkdir -p ${_d} || {
			echo "ERROR: failed to make directory [${_d}]"
			exit 1
		}
	else
		[[ ${DEBUG} ]] && echo -e "${_d}\t already exists"
	fi
}

function create_user {
	local user=$1
	local uid=$2
	# check no id for user exists
	local _id=$(id ${uid} 2> /dev/null)
	if [[ ${_id} ]]; then
		echo -e "User with id ${uid} already created"
		echo -e "ID:\t [${_id}]"
	else
		sudo useradd --no-create-home --system --shell /sbin/nologin --uid ${uid} ${user}
		echo "User '${user}' id ${uid} created"
	fi
}

function clamav_dir {
	sudo chmod 755 ${CLAMAV_PATH}
	sudo chown -R ${CLAMAV_USER} ${CLAMAV_PATH}
	echo "Chmod'd/Chown'd ${CLAMAV_USER} ${CLAMAV_PATH}"
}

function prometheus_configs {
	local _cfgDir="$(dirname ${ENVFILE})/prom-cfg"
	if [[ -d ${_cfgDir}/ ]]; then
		cp ${_cfgDir}/* ${PROMETHEUS_CFG_PATH}/
		echo "Copied prometheus configs"
	else
		echo "ERROR: directory of prometheus configs missing"
		exit 1
	fi
}

function add_empty_surts {
	touch ${HERITRIX_SURTS_PATH}/surts.txt
	touch ${HERITRIX_SURTS_PATH}/excluded-surts.txt
}

function dir_permissions {
	sudo chmod 755 ${STORAGE_PATH}/heritrix/
	sudo chown -R ${HERITRIX_USER_ID}:${HERITRIX_USER_ID} ${STORAGE_PATH}/heritrix/
	echo "Chmod'd/Chown'd ${HERITRIX_USER} ${STORAGE_PATH}/heritrix/"

	sudo chmod 755 ${CDX_STORAGE_PATH}/
	sudo chown -R ${USER}:${USER} ${CDX_STORAGE_PATH}/
	echo "Chmod'd/Chown'd ${USER} ${CDX_STORAGE_PATH}"

	sudo chmod 755 ${KAFKA_PATH}/
	sudo chown -R ${USER}:${USER} ${KAFKA_PATH}/
	echo "Chmod'd/Chown'd ${USER} ${KAFKA_PATH}"
}

# script -------------------
test_env_file
test_storage_path

for _d in \
	${TMP_STORAGE_PATH} ${KAFKA_PATH} ${CLAMAV_PATH} ${PROMETHEUS_CFG_PATH} ${PROMETHEUS_DATA_PATH} \
	${CDX_STORAGE_PATH} ${HERITRIX_HOME_PATH} ${HERITRIX_OUTPUT_PATH} ${HERITRIX_STATE_PATH} ${HERITRIX_SCRATCH_PATH} \
       	${HERITRIX_LOG_PATH} ${HERITRIX_SURTS_PATH} ${NPLD_STATE_PATH} ${WARCPROX_PATH} \
	; do make_directory ${_d}
done

echo -e "\n${STORAGE_PATH} tree structure"
tree -d ${STORAGE_PATH} | less --no-init --quit-if-one-screen

echo
check_repos_exist
echo
install_docker_compose
echo
create_user ${CLAMAV_USER} ${CLAMID}
echo
clamav_dir
echo
prometheus_configs
echo
create_user ${HERITRIX_USER} ${HERITRIX_USER_ID}
echo
add_empty_surts
echo
dir_permissions
echo -e "Completed -----------------------\n"
