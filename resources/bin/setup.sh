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

pre_install() {
	apt-get update -q 2>&1
	apt-get install -yq ${packages[@]} 2>&1
}

post_install(){
    apt-get autoremove
    apt-get clean
	rm -fr /var/lib/apt
}

install_mistio() {
    git clone https://github.com/mistio/mist.io.git /opt/mistio 2>&1
    pushd /opt/mistio
    virtualenv -p python2.7 .
    /opt/mistio/bin/pip install ansible 2>&1
    /opt/mistio/bin/pip install setuptools --upgrade 2>&1
    /opt/mistio/bin/python bootstrap.py 2>&1
    /opt/mistio/bin/buildout -v 2>&1
    popd
}

build() {
	if [ ! -f "${INSTALL_LOG}" ]
	then
		touch "${INSTALL_LOG}"
	fi

	tasks=(
		'pre_install'
		'install_mistio'
	)

	for task in ${tasks[@]}
	do
		echo "Running build task ${task}..."
		${task} | tee -a "${INSTALL_LOG}" || exit 1
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
    for task in ${@}
	do
		echo "Running ${task}..."
		${task} || exit 1
	done
fi
