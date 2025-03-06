### 文件轮换⭐

1. 安装 `logrotate`：

   ```bash
   sudo apt install logrotate
   ```

2. 创建另一个配置文件 `/etc/logrotate.d/db_redis_sync`：

   ```bash
   sudo nano /etc/logrotate.d/db_redis_sync
   ```

   在新配置文件中添加以下内容：

   ```bash
   /var/log/db_redis_sync.log { # 原来日志文件的地址，需要最好自己创建出来赋予权限
       daily          # 按天轮换
       rotate 7       # 保留最近7天日志
       compress       # 压缩旧日志
       missingok      # 如果日志文件不存在，不报错
       notifempty     # 如果日志为空，不轮换
       create 0644 $USER $USER  # 轮换后创建新文件并设置权限
   }
   
   ```

日志按天轮换压缩，避免占用过多磁盘空间。

文件路径是自己的，新路径可以自定义，自行修改~~