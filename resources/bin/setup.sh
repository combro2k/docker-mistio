#!/bin/bash

trap '{ echo -e "error ${?}\nthe command executing at the time of the error was\n${BASH_COMMAND}\non line ${BASH_LINENO[0]}" && tail -n 10 ${INSTALL_LOG} && exit $? }' ERR

export DEBIAN_FRONTEND=noninteractive
export packages=(
    'curl'
    'python-dev'
    'python-virtualenv'
    'build-essential'
    'python-setuptools'
    'git'
    'erlang'
    'wget'
)

create_users() {
    if [ ! -d "${APP_USER}" ]
	then
		echo "Creating user ${APP_USER}..."

		useradd -d "${APP_HOME}" -m -s "/bin/bash" "${APP_USER}"
	fi

	return 0
}
pre_install() {
	apt-get update -q 2>&1
	apt-get install -yq ${packages[@]} 2>&1
}

install_mistio() {
    mkdir -p /app/mistio
    git clone https://github.com/mistio/mist.io.git /app/mistio
    pushd /app/mistio
    virtualenv -p python2.7 .
    ./bin/pip install ansible
    ./bin/pip install setuptools --upgrade
    ./bin/python bootstrap.py
    ./bin/buildout -v
    popd
}

build() {
	if [ ! -f "${INSTALL_LOG}" ]
	then
		touch "${INSTALL_LOG}"
	fi

	tasks=(
		'pre_install'
	)

	for task in ${tasks[@]}
	do
		echo "Running build task ${task}..."
		${task} | tee -a "${INSTALL_LOG}" > /dev/null 2>&1 || exit 1
	done
}

if [ $# -eq 0 ]
then
	echo "No parameters given! (${@})"
	echo "Available functions:"
	echo

	compgen -A function

	exit 1
else
    if [ -z "${rvm_prefix}" ]
    then
        load_rvm
    fi

	for task in ${@}
	do
		echo "Running ${task}..."
		${task} || exit 1
	done
fi
