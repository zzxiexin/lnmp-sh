#!/bin/bash

# 更新系统
echo "正在更新系统..."
yum update -y

# 安装 Nginx
echo "正在安装 Nginx..."
yum install -y epel-release
yum install -y nginx

# 安装 MySQL
echo "正在安装 MySQL..."
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld
mysql_secure_installation

# 安装 PHP
echo "正在安装 PHP 和相关扩展..."
yum install -y php php-fpm php-mysql php-cli php-curl php-mbstring php-xml php-bcmath

# 配置 Nginx 支持 PHP
echo "配置 Nginx 支持 PHP..."
cat > /etc/nginx/nginx.conf <<EOF
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 启动 Nginx 和 PHP-FPM
echo "启动 Nginx 和 PHP-FPM 服务..."
systemctl start nginx
systemctl enable nginx
systemctl start php-fpm
systemctl enable php-fpm

# 测试安装
echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php
echo "安装完成！请访问 http://你的IP地址/info.php 测试 PHP 是否正常工作。"
