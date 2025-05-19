#!/bin/bash

# ========== KONFIGURASI ========== #
DB_NAME="wordpress_db"
DB_USER="wpuser"
NGINX_SITE="wordpress"
WEB_ROOT="/var/www/html"

echo "🚨 Mulai proses penghapusan WordPress..."

# ========== 1. Hapus file WordPress ========== #
if [ -d "$WEB_ROOT" ]; then
    echo "🧹 Menghapus direktori $WEB_ROOT..."
    sudo rm -rf "$WEB_ROOT"
else
    echo "📁 Direktori $WEB_ROOT tidak ditemukan, lewati..."
fi

# ========== 2. Hapus database dan user MySQL ========== #
echo "🗃️ Menghapus database dan user MySQL..."
sudo mysql -u root <<MYSQL_SCRIPT
DROP DATABASE IF EXISTS $DB_NAME;
DROP USER IF EXISTS '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# ========== 3. Hapus konfigurasi Nginx ========== #
NGINX_AVAILABLE="/etc/nginx/sites-available/$NGINX_SITE"
NGINX_ENABLED="/etc/nginx/sites-enabled/$NGINX_SITE"

if [ -f "$NGINX_ENABLED" ]; then
    echo "🔌 Menonaktifkan site Nginx..."
    sudo rm "$NGINX_ENABLED"
fi

if [ -f "$NGINX_AVAILABLE" ]; then
    echo "🗑️ Menghapus konfigurasi site $NGINX_SITE..."
    sudo rm "$NGINX_AVAILABLE"
fi

# ========== 4. Restart Nginx ========== #
echo "🔁 Me-restart Nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo "✅ WordPress berhasil dihapus!"
