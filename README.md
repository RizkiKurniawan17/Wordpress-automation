---

## 📘 README – Script Instalasi WordPress Otomatis

### 🛠️ Deskripsi

Script Bash ini digunakan untuk **menginstal WordPress secara otomatis** di server **Ubuntu atau Debian**, dengan pilihan web server **Apache** atau **Nginx**, lengkap dengan pengaturan database MySQL dan (opsional) HTTPS dengan Let's Encrypt.

---

### 📋 Persyaratan

* Sistem Operasi: **Ubuntu/Debian**
* Akses sebagai **root** (superuser)
* Koneksi internet aktif
* Nama domain aktif (jika ingin menggunakan HTTPS)

---

### 📥 Cara Menggunakan

1. **Upload atau salin script ke server**
   ```bash
   git clone
   cd Wordpress-automation
   ```

2. **Jadikan script executable**

   ```bash
   chmod +x install-wordpress.sh
   ```

3. **Jalankan script sebagai root**

   ```bash
   sudo ./install-wordpress.sh
   ```

4. **Ikuti petunjuk interaktif**:

   * Pilih web server: `apache` atau `nginx`
   * Pilih apakah ingin menjalankan `mysql_secure_installation`
   * Masukkan:

     * Nama database WordPress
     * Username database
     * Password database
   * Masukkan **domain atau IP publik** server mu
   * Pilih apakah ingin mengaktifkan HTTPS (Let's Encrypt)

5. **Akses WordPress**
   Buka browser dan kunjungi:

   ```
   http://yourdomain.com / http://ip
   ```

   atau:

   ```
   https://yourdomain.com (jika HTTPS diaktifkan)
   ```

   Ikuti langkah-langkah setup WordPress di browser.
