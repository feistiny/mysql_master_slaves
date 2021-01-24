FROM mysql:5.7.33

RUN mkdir /usr/local/mysql && \
	chown mysql:adm /usr/local/mysql

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from deb.debian.org to aliyun source
    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    echo 'source changed' \
;fi

RUN apt-get update -yqq && \
	apt-get install -yqq iputils-ping telnet procps wget && \
	apt-get clean

ARG IS_MASTER=false
RUN if [ ${IS_MASTER} = true ]; then \
	echo "build master" && \
	wget https://downloads.percona.com/downloads/percona-toolkit/3.3.0/binary/debian/buster/x86_64/percona-toolkit_3.3.0-1.buster_amd64.deb && \
	apt install -yqq ./percona-toolkit_3.3.0-1.buster_amd64.deb \
;else \
	echo "build slave" \
;fi
