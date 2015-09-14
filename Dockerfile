FROM combro2k/debian-debootstrap:8

MAINTAINER Martijn van Maurik <docker@vmaurik.nl>

# Environment variables
ENV HOME=/opt/mistio \
    INSTALL_LOG=/var/log/build.log

# Add resources
ADD resources/bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* && touch ${INSTALL_LOG} && /bin/bash -l -c '/usr/local/bin/setup.sh build'

CMD ['/opt/mistio/bin/supervisord']