#!/bin/bash

# Docker 容器和数据库配置
DOCKER_CONTAINER="your_mysql_container_name"  # Docker 容器名称
DB_USER="your_db_user"                        # 数据库用户名
DB_PASSWORD="your_db_password"                # 数据库密码

# 定义三个数据库及其对应的 SQL 文件路径
declare -A DATABASES=(
  ["database1"]="/path/to/database1.sql"     # 数据库1名称和对应的SQL文件
  ["database2"]="/path/to/database2.sql"     # 数据库2名称和对应的SQL文件
  ["database3"]="/path/to/database3.sql"     # 数据库3名称和对应的SQL文件
)

# 遍历所有数据库并执行对应的 SQL 文件
for db_name in "${!DATABASES[@]}"; do
  sql_file="${DATABASES[$db_name]}"
  echo "正在同步数据库 [$db_name]，使用文件: $sql_file"

  # 检查 SQL 文件是否存在
  if [ ! -f "$sql_file" ]; then
    echo "错误: SQL 文件 $sql_file 不存在！"
    continue  # 跳过当前循环，继续下一个数据库
  fi

  # 执行导入命令
  docker exec -i $DOCKER_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD $db_name < $sql_file

  # 检查执行结果
  if [ $? -eq 0 ]; then
    echo "[$db_name] 同步成功"
  else
    echo "[$db_name] 同步失败！"
  fi
done