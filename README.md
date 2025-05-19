# 🛠️ WordPress Automation Scripts

This repository contains automation scripts for installing and removing WordPress using **Bash** on **Ubuntu Server 22.04** with **Nginx**, **PHP**, and **MariaDB**.  
The project simplifies the WordPress setup and teardown process by executing a series of automated commands.

---

## 📥 Installation Steps

Follow these steps to install WordPress using these scripts:

### 1. Clone the Repository

Clone this repository to your server:

```bash
git clone https://github.com/RizkiKurniawan17/Wordpress-automation.git
````

---

### 2. Access the Project Directory

Navigate into the cloned directory:

```bash
cd Wordpress-automation
```

---

### 3. Run the Installation Script

Execute the script to install WordPress:

```bash
bash install-wordpress.sh
# or
chmod +x install-wordpress.sh && ./install-wordpress.sh
```

---

### 4. Database & WordPress Configuration

During the script execution, you will be prompted to go through the `mysql_secure_installation`. Recommended answers:

* Validate password plugin: `n`
  *(Recommended to avoid password complexity issues, especially for local use)*
* Remove anonymous users: `y`
* Disallow root login remotely: `n` *(only if **not** using in production)*
* Remove test database: `y`
* Reload privilege tables: `y`

After this step, the script will also prompt you to input WordPress database configuration:

* **WordPress database name**
* **Database username**
* **Database user password**

These credentials will be used to configure `wp-config.php`.

---

### 5. Complete the Installation

Once the script completes, WordPress will be installed and accessible at:

```
http://<your-server-ip>
```

Proceed with the WordPress setup through the web browser.

---

## 🧹 Uninstallation (Remove WordPress)

To remove the WordPress installation and its related components:

```bash
bash remove-wordpress.sh
# or
chmod +x remove-wordpress.sh && ./remove-wordpress.sh
```

The removal script will:

* Read database config from `wp-config.php`
* Remove WordPress files
* Drop the corresponding database and user
* Remove Nginx configuration and reload Nginx

---

## 📝 Notes

* These scripts require **Bash** and are intended for **Ubuntu Server 22.04**.
* If you're using **Windows**, it's recommended to run via **WSL** (Windows Subsystem for Linux).
* **Do not use this setup as-is in production** without securing your environment.

---

## 📄 License

This project is licensed under the MIT License.

```

