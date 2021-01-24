# 定义变量
MKFILE_PATH:=$(abspath $(firstword ${MAKEFILE_LIST}))
MKFILE_DIR:=$(shell dirname ${MKFILE_PATH})

include ${MKFILE_DIR}/../.env

#定义函数
define docker_mysql_exec
docker exec -i ${1} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${2} -e "${3}" 2>/dev/null
endef

.SILENT:
.ONESHELL:
.DEFAULT_GOAL:=all

.SHELLFLAGS=-ec
# 用 bash 支持 (()) 的算术运算
SHELL=/bin/bash

test:
	echo ${MYSQL_ROOT_PASSWORD}
	echo ${MS_MASTER}

all: change_master hard_link grant
	echo ${MKFILE_PATH} 完成

grant:
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},, grant all privileges on *.*  to 'root'@'172.200.10.%' identified by '${MYSQL_ROOT_PASSWORD}';)

change_master:
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},,stop slave;) || true
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},,reset slave;) || true
	#echo \
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},,change master to \
		master_user='slave'$(COMMA) \
		master_password='${SLAVE_PASSWORD}'$(COMMA) \
		master_host='${MASTER1_IP}'$(COMMA) \
		master_log_file='$(shell cat ${MKFILE_DIR}/../master1/mysql-bin.txt)'$(COMMA) \
		master_log_pos=$(shell cat ${MKFILE_DIR}/../master1/log-pos.txt); \
	) && echo "change master ok" || echo "change master fail"
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},,start slave;) && echo "start slave ok" || echo "start slave fail"
	$(call docker_mysql_exec, ${CONTAINER_SLAVE1},,show slave status\G;) | grep -i Running

hard_link:
	ln -f ${MKFILE_DIR}/../master1/etc/mysqld.d/base.cnf ${MKFILE_DIR}/etc/mysqld.d/base.cnf
	ln -f ${MKFILE_DIR}/../master1/etc/mysql.d/mysql.cnf ${MKFILE_DIR}/etc/mysql.d/mysql.cnf
	echo "hard link ok"




