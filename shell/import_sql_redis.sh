#!/bin/bash

# --------------------------
# Docker 容器配置
# --------------------------
DOCKER_MYSQL="your_mysql_container"    # MySQL 容器名称
DOCKER_REDIS="your_redis_container"    # Redis 容器名称

# --------------------------
# MySQL 数据库配置
# --------------------------
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"
declare -A DATABASES=(
  ["database1"]="/path/to/database1.sql"
  ["database2"]="/path/to/database2.sql"
  ["database3"]="/path/to/database3.sql"
)

# --------------------------
# 延时双删参数
# --------------------------
DELAY_SECONDS=5  # 等待时间（秒），根据业务需求调整

# --------------------------
# 主逻辑
# --------------------------
error_flag=0  # 全局错误标记

# 步骤 1: 第一次清理 Redis 缓存
echo "[1/4] 第一次清理 Redis 缓存..."
docker exec $DOCKER_REDIS redis-cli flushall >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "第一次清理成功"
else
  echo "第一次清理失败！"
  error_flag=1  # 可选项：如果第一次清理失败直接终止任务，移除此行则不终止
fi

# 步骤 2: 同步 MySQL 数据库
echo "[2/4] 开始同步数据库..."
for db_name in "${!DATABASES[@]}"; do
  sql_file="${DATABASES[$db_name]}"
  if [ ! -f "$sql_file" ]; then
    echo "错误: SQL 文件 $sql_file 不存在！"
    error_flag=1
    continue
  fi

  docker exec -i $DOCKER_MYSQL mysql -u$DB_USER -p$DB_PASSWORD $db_name < "$sql_file"
  if [ $? -ne 0 ]; then
    echo "[$db_name] 同步失败！"
    error_flag=1
  else
    echo "[$db_name] 同步成功"
  fi
done

# 步骤 3-4: 仅当数据库同步成功时执行第二次清理
if [ $error_flag -eq 0 ]; then
  echo "[3/4] 等待 ${DELAY_SECONDS} 秒..."
  sleep $DELAY_SECONDS

  echo "[4/4] 执行第二次 Redis 缓存清理..."
  docker exec $DOCKER_REDIS redis-cli flushall >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "第二次清理成功"
  else
    echo "第二次清理失败！"
  fi
else
  echo "[3/4] 数据库同步失败，跳过第二次缓存清理"
fi