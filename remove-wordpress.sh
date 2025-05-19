#!/bin/bash

print_green() { echo -e "\e[32m$1\e[0m"; }
print_red() { echo -e "\e[31m$1\e[0m"; }

# Cek user
if [[ $EUID -ne 0 ]]; then
    print_red "Script ini harus dijalankan sebagai root!"
    exit 1
fi

read -p "Gunakan Apache atau Nginx? (apache/nginx): " web_server
if [[ "$web_server" != "apache" && "$web_server" != "nginx" ]]; then
    print_red "Input salah. Masukkan 'apache' atau 'nginx'."
    exit 1
fi

read -p "Masukkan nama domain/server yang digunakan: " domain_name

print_green "Menghapus file WordPress..."
rm -rf /var/www/html/*

print_green "Menghapus konfigurasi web server..."
if [[ "$web_server" == "apache" ]]; then
    a2dissite wordpress.conf
    rm -f /etc/apache2/sites-available/wordpress.conf
    systemctl reload apache2
else
    rm -f /etc/nginx/sites-enabled/wordpress
    rm -f /etc/nginx/sites-available/wordpress
    systemctl reload nginx
fi

read -p "Hapus database dan user MySQL juga? (y/n): " del_db
if [[ "$del_db" =~ ^[Yy]$ ]]; then
    read -p "Masukkan nama database WordPress: " wp_db
    read -p "Masukkan nama user database WordPress: " wp_user

    mysql -e "DROP DATABASE IF EXISTS ${wp_db};"
    mysql -e "DROP USER IF EXISTS '${wp_user}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    print_green "Database dan user MySQL telah dihapus."
fi

print_green "Uninstall selesai. WordPress dan konfigurasi terkait telah dihapus."
```