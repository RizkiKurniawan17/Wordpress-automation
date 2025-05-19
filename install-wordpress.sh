#!/bin/bash

# SETUP VARIABEL
DB_NAME="wordpress_db"
DB_USER="wpuser"
DB_PASS="passwordku"
DOMAIN="wordpress.local"
WP_DIR="/var/www/$DOMAIN"

echo "======================================"
echo "INSTALL WORDPRESS DI UBUNTU 22.04"
echo "======================================"

# 1. UPDATE & INSTALL NGINX, MARIADB, PHP
echo "[1/7] Update sistem dan install paket..."
sudo apt update && sudo apt upgrade -y
sudo apt install nginx mariadb-server php-fpm php-mysql php-gd php-curl php-xml php-mbstring php-zip php-intl php-soap unzip curl wget -y

# 2. SETUP DATABASE
echo "[2/7] Membuat database dan user MariaDB..."
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Konfigurasi keamanan dasar MariaDB (otomatis, non-interaktif)
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$DB_PASS') WHERE User = 'root';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Membuat database dan user WordPress
sudo mysql -u root -p$DB_PASS -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -u root -p$DB_PASS -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -u root -p$DB_PASS -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -u root -p$DB_PASS -e "FLUSH PRIVILEGES;"

# 3. DOWNLOAD WORDPRESS
echo "[3/7] Mengunduh dan menyalin WordPress..."
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo mkdir -p $WP_DIR
sudo cp -r wordpress/* $WP_DIR

# 4. SETUP PERMISSIONS
echo "[4/7] Mengatur izin folder WordPress..."
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 755 $WP_DIR

# 5. KONFIGURASI wp-config.php
echo "[5/7] Konfigurasi wp-config.php..."
cd $WP_DIR
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASS/" wp-config.php

# Tambahkan salt key
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/AUTH_KEY/d" wp-config.php
sudo sed -i "/SECURE_AUTH_KEY/d" wp-config.php
sudo sed -i "/LOGGED_IN_KEY/d" wp-config.php
sudo sed -i "/NONCE_KEY/d" wp-config.php
sudo sed -i "/AUTH_SALT/d" wp-config.php
sudo sed -i "/SECURE_AUTH_SALT/d" wp-config.php
sudo sed -i "/LOGGED_IN_SALT/d" wp-config.php
sudo sed -i "/NONCE_SALT/d" wp-config.php
sudo echo "$SALT" >> wp-config.php

# 6. KONFIGURASI NGINX
echo "[6/7] Konfigurasi virtual host Nginx..."
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    root $WP_DIR;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 7. FINISHING
echo "[7/7] Instalasi selesai!"
echo "--------------------------------------"
echo "Tambahkan entri berikut ke /etc/hosts:"
echo "127.0.0.1  $DOMAIN"
echo "Lalu akses: http://$DOMAIN"
echo "--------------------------------------"
