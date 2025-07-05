#!/bin/bash

# 更新系统
echo "正在更新系统..."
apt update -y && apt upgrade -y

# 安装 Nginx
echo "正在安装 Nginx..."
apt install -y nginx

# 安装 MySQL
echo "正在安装 MySQL..."
apt install -y mysql-server
mysql_secure_installation

# 安装 PHP
echo "正在安装 PHP 和相关扩展..."
apt install -y php-fpm php-mysql php-cli php-curl php-mbstring php-xml php-bcmath

# 配置 Nginx 支持 PHP
echo "配置 Nginx 支持 PHP..."
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 重启 Nginx 和 PHP-FPM
echo "重启 Nginx 和 PHP-FPM 服务..."
systemctl restart nginx
systemctl restart php7.4-fpm

# 测试安装
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
echo "安装完成！请访问 http://你的IP地址/info.php 测试 PHP 是否正常工作。"

