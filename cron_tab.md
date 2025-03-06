### 使用cron表达式定期执行🤖



#### 编辑当前用户的 Cron 配置文件

```bash
crontab -e
```



#### 添加定时任务行

注意修改为自己的路径

```bash
0 0 * * * /opt/import_sql.sh >> /var/log/db_redis_sync.log 2>&1
```



#### 查看当前用户的 Cron 任务列表

```bash
crontab -l
```



#### **检查 Cron 服务状态**：

```bash
sudo systemctl status cron
```

确保服务状态为 `active (running)`。