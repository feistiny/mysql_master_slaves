MKFILE_PATH:=$(abspath $(firstword ${MAKEFILE_LIST}))
MKFILE_DIR:=$(shell dirname ${MKFILE_PATH})

include ${MKFILE_DIR}/.env

.SILENT:
.ONESHELL:
.DEFAULT_GOAL:=all

test:
#	$(MAKE) -f ${MKFILE_DIR}/master1/Makefile
#	$(MAKE) -f ${MKFILE_DIR}/master2/Makefile
#	# 双主
#	$(MAKE) -f ${MKFILE_DIR}/master1/Makefile master_master
#	$(MAKE) -f ${MKFILE_DIR}/master2/Makefile master_master

all: build cp_env
	echo 开始

	docker-compose up -d --remove-orphans

	$(MAKE) -f ${MKFILE_DIR}/master1/Makefile
	$(MAKE) -f ${MKFILE_DIR}/master2/Makefile

	# 双主
	$(MAKE) -f ${MKFILE_DIR}/master1/Makefile master_master
	$(MAKE) -f ${MKFILE_DIR}/master2/Makefile master_master

	# 从库
	$(MAKE) -f ${MKFILE_DIR}/slave1/Makefile
	$(MAKE) -f ${MKFILE_DIR}/slave2/Makefile

	echo 完成

build: ./docker/Dockerfile
	echo build docker

	for is_master in true false;do
		if $$is_master; then IMAGE_NAME=$(MYSQL_MASTER_IMAGE); else IMAGE_NAME=$(MYSQL_SLAVE_IMAGE); fi
		docker build \
		--build-arg CHANGE_SOURCE="${CHANGE_SOURCE}" \
		--build-arg IS_MASTER="$$is_master" \
		--build-arg http_proxy \
		--build-arg https_proxy \
		-t $${IMAGE_NAME} ./docker
	done

cp_env:
	[ -f ${MKFILE_DIR}/.env ] || cp .env.example .env
