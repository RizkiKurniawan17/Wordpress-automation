#!/bin/bash

# ======== Fungsi warna =========
print_green() { echo -e "\e[32m$1\e[0m"; }
print_red() { echo -e "\e[31m$1\e[0m"; }

# ======== Validasi OS & root =========
if ! grep -E "Ubuntu|Debian" /etc/os-release > /dev/null; then
    print_red "This script only supports Ubuntu or Debian."
    exit 1
fi
if [[ $EUID -ne 0 ]]; then
    print_red "This script must be run as root."
    exit 1
fi

# ======== Pilihan Web Server =========
read -p "Do you want to use Apache or Nginx? (apache/nginx): " web_server
if [[ "$web_server" != "apache" && "$web_server" != "nginx" ]]; then
    print_red "Invalid choice. Please enter 'apache' or 'nginx'."
    exit 1
fi

# ======== Update & Install Dependencies =========
print_green "Updating system and installing packages..."
apt update && apt upgrade -y

# Deteksi versi PHP
php_version=$(apt-cache search ^php$ | awk '{print $1}' | grep -oP '[0-9]+\.[0-9]+' | sort -nr | head -n1)
php_version=${php_version:-8.1}

if [[ $web_server == "apache" ]]; then
    apt install -y apache2 mariadb-server php$php_version libapache2-mod-php$php_version php$php_version-mysql \
                   php$php_version-xml php$php_version-mbstring php$php_version-curl php$php_version-zip \
                   php$php_version-common php$php_version-cli php$php_version-json
else
    apt install -y nginx mariadb-server php-fpm php-mysql php-xml php-mbstring php-curl php-zip php-common php-cli php-json
fi

# ======== Konfigurasi MySQL =========
read -p "Do you want to run mysql_secure_installation? (y/n): " run_secure
if [[ "$run_secure" =~ ^[Yy]$ ]]; then
    mysql_secure_installation
fi

read -p "WordPress Database Name: " wp_db
read -p "WordPress DB Username: " wp_user
read -sp "WordPress DB Password: " wp_pass
echo
print_green "Creating MySQL database and user..."

mysql -e "CREATE DATABASE ${wp_db} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" || true
mysql -e "CREATE USER '${wp_user}'@'localhost' IDENTIFIED BY '${wp_pass}';" || true
mysql -e "GRANT ALL PRIVILEGES ON ${wp_db}.* TO '${wp_user}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# ======== Install WordPress =========
print_green "Downloading and installing WordPress..."
rm -rf /var/www/html/*
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
mv wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

# ======== Buat wp-config.php =========
print_green "Configuring WordPress..."
cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${wp_db}');
define('DB_USER', '${wp_user}');
define('DB_PASSWORD', '${wp_pass}');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
EOF

curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php

cat >> /var/www/html/wp-config.php << 'EOF'

$table_prefix = 'wp_';
define('WP_DEBUG', false);
if ( ! defined( 'ABSPATH' ) ) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOF

# ======== Permission =========
print_green "Setting permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# ======== Input domain =========
read -p "Enter your domain name or server IP: " domain_name

# ======== Konfigurasi Apache atau Nginx =========
if [[ $web_server == "apache" ]]; then
    print_green "Configuring Apache virtual host..."
    cat > /etc/apache2/sites-available/wordpress.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@${domain_name}
    DocumentRoot /var/www/html
    ServerName ${domain_name}

    <Directory /var/www/html>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    a2ensite wordpress.conf
    a2enmod rewrite
    systemctl restart apache2
else
    print_green "Configuring Nginx server block..."
    php_fpm_socket=$(find /var/run/php/ -name "php*-fpm.sock" | head -n 1)

    cat > /etc/nginx/sites-available/wordpress << EOF
server {
    listen 80;
    server_name ${domain_name};
    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${php_fpm_socket};
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    unlink /etc/nginx/sites-enabled/default 2>/dev/null || true
    ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
fi

# ======== Opsi HTTPS =========
read -p "Do you want to enable HTTPS using Let's Encrypt? (y/n): " enable_https
if [[ "$enable_https" =~ ^[Yy]$ ]]; then
    apt install certbot python3-certbot-nginx -y
    certbot --nginx -d $domain_name
fi

# ======== Selesai =========
print_green "====================================="
print_green "WordPress installation complete!"
print_green "Visit: http://$domain_name"
print_green "Finish setup via browser."
print_green "====================================="
