#!/bin/sh
ENVFILE=$1
CLAMUSER=clamav
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

function create_clamav_user {
	# check no 100 id user exists
	id100=$(id 100 2> /dev/null)
	if [[ ${id100} ]]; then
		echo -e "User with id 100 already created"
		echo -e "ID:\t [${id100}]"
	else
		sudo useradd --no-create-home --system --shell /sbin/nologin --uid 100 ${CLAMUSER}
		echo "User '${CLAMUSER}' id 100 created"
	fi
}

function clamav_dir {
	sudo chmod 755 ${CLAMAV_PATH}
	sudo chown -R ${CLAMUSER} ${CLAMAV_PATH}
	echo "Chmod'd/Chown'd ${CLAMUSER} ${CLAMAV_PATH}"
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

function create_empty_surts {
	local _sf
	for _sf in ${SURTS_NPLD_PATH}/surts.txt ${SURTS_NPLD_PATH}/excluded-surts.txt; do
		if ! [[ -f ${_sf} ]]; then
			touch ${_sf}
			echo "Created surt file ${_sf}"
		fi
	done
}

# script -------------------
test_env_file
test_storage_path

for _d in \
	${TMP_STORAGE_PATH} ${KAFKA_PATH} ${CLAMAV_PATH} ${PROMETHEUS_CFG_PATH} ${PROMETHEUS_DATA_PATH} \
	${CDX_STORAGE_PATH} ${HERITRIX_HOME_PATH} ${HERITRIX_OUTPUT_PATH} ${HERITRIX_STATE_PATH} ${HERITRIX_SCRATCH_PATH} \
       	${HERITRIX_LOG_PATH} ${SURTS_NPLD_PATH} ${NPLD_STATE_PATH} ${WARCPROX_PATH} \
	; do make_directory ${_d}
done

echo -e "\n${STORAGE_PATH} tree structure"
tree -d ${STORAGE_PATH} | less --no-init --quit-if-one-screen

create_clamav_user
clamav_dir
prometheus_configs
create_empty_surts
echo
