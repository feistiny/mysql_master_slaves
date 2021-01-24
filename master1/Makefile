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

test:
	echo ${MYSQL_ROOT_PASSWORD}
	echo ${MS_MASTER}
	echo $(COMMA)
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},, show databases;)

all: master_grant master_status
	echo ${MKFILE_PATH} 完成

master_grant:
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},, grant all privileges on *.*  to 'root'@'172.200.10.%' identified by '${MYSQL_ROOT_PASSWORD}';)

	$(call docker_mysql_exec, ${CONTAINER_MASTER1},, grant replication slave on *.*  to 'slave'@'172.200.10.%' identified by '${SLAVE_PASSWORD}';)
	#重新加载权限表
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},, flush privileges;)

master_status:
	$(call docker_mysql_exec, ${CONTAINER_MASTER1}, --skip-column-names, show master status;) | awk '{print $$1}' > ${MKFILE_DIR}/mysql-bin.txt
	$(call docker_mysql_exec, ${CONTAINER_MASTER1}, --skip-column-names, show master status;) | awk '{print $$2}' > ${MKFILE_DIR}/log-pos.txt

master_master:
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},,stop slave;)
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},,reset slave;) || true
	#echo \
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},,change master to \
		master_user='slave'$(COMMA) \
		master_password='${SLAVE_PASSWORD}'$(COMMA) \
		master_host='${MASTER2_IP}'$(COMMA) \
		master_log_file='$(shell cat ${MKFILE_DIR}/../master2/mysql-bin.txt)'$(COMMA) \
		master_log_pos=$(shell cat ${MKFILE_DIR}/../master2/log-pos.txt); \
	) && echo "change master ok" || echo "change master fail"
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},,start slave;) && echo "start slave ok" || echo "start slave fail"
	$(call docker_mysql_exec, ${CONTAINER_MASTER1},,show slave status\G;) | grep -i Running


