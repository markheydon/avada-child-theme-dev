#!/usr/bin/env bash
set -euo pipefail

cd /workspace

echo "==> Installing Composer dependencies"
composer install

echo "==> Waiting for WordPress files"
MAX_WORDPRESS_FILE_ATTEMPTS=30
WORDPRESS_FILE_ATTEMPT=0

until [ -f /var/www/html/wp-load.php ]; do
    WORDPRESS_FILE_ATTEMPT=$((WORDPRESS_FILE_ATTEMPT + 1))
    if [ "$WORDPRESS_FILE_ATTEMPT" -ge "$MAX_WORDPRESS_FILE_ATTEMPTS" ]; then
        echo "ERROR: WordPress files did not become available in /var/www/html in time"
        echo "Check the wordpress bind mount at /workspace/wordpress and container startup logs."
        exit 1
    fi

    echo "Waiting for WordPress files... ($WORDPRESS_FILE_ATTEMPT/$MAX_WORDPRESS_FILE_ATTEMPTS)"
    sleep 2
done

echo "==> Waiting for database"

MAX_ATTEMPTS=30
ATTEMPT=0

until wp db check --path=/var/www/html --allow-root >/dev/null 2>&1; do
    ATTEMPT=$((ATTEMPT + 1))
    if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
        echo "ERROR: Database did not become ready in time"
        echo "Check docker logs for the db container and confirm credentials/volumes are correct."
        exit 1
    fi

    echo "Waiting for database... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
done

echo "==> Database ready"

echo "==> Ensuring writable WordPress content directories"
sudo chmod 2775 /var/www/html/wp-content
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/themes
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/plugins
sudo chgrp www-data /var/www/html/wp-content/themes
sudo chmod 2775 /var/www/html/wp-content/themes
sudo chgrp -R www-data /var/www/html/wp-content/plugins
sudo find /var/www/html/wp-content/plugins -type d -exec chmod 2775 {} +
sudo find /var/www/html/wp-content/plugins -type f -exec chmod 0664 {} +
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/upgrade
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/languages
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/languages/plugins
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/languages/themes
sudo chgrp -R www-data /var/www/html/wp-content/languages
sudo find /var/www/html/wp-content/languages -type d -exec chmod 2775 {} +
sudo find /var/www/html/wp-content/languages -type f -exec chmod 0664 {} +
sudo install -d -m 2775 -o www-data -g www-data /var/www/html/wp-content/uploads
sudo chgrp -R www-data /var/www/html/wp-content/uploads
sudo find /var/www/html/wp-content/uploads -type d -exec chmod 2775 {} +
sudo find /var/www/html/wp-content/uploads -type f -exec chmod 0664 {} +

ensure_uk_locale() {
    echo "==> Installing UK English language pack"
    if ! wp language core install en_GB --path=/var/www/html --allow-root; then
        echo "ERROR: Failed to install en_GB language pack."
        exit 1
    fi

    if ! wp site switch-language en_GB --path=/var/www/html --allow-root; then
        echo "ERROR: Failed to switch site language to en_GB."
        exit 1
    fi

    ACTIVE_LOCALE="$(wp option get WPLANG --path=/var/www/html --allow-root | tr -d '\r')"
    if [ "$ACTIVE_LOCALE" != "en_GB" ]; then
        echo "ERROR: Expected active locale en_GB but found '$ACTIVE_LOCALE'."
        exit 1
    fi
}

if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
    echo "==> Installing WordPress"
    wp core install \
        --path=/var/www/html \
        --url="http://localhost:8080" \
        --title="Local Development Site" \
        --admin_user="admin" \
        --admin_password="admin" \
        --admin_email="admin@example.com" \
        --skip-email \
        --allow-root
    ensure_uk_locale
else
    echo "==> WordPress already installed"
    ensure_uk_locale
fi

echo "==> Applying regional settings"
wp option update timezone_string "Europe/London" --path=/var/www/html --allow-root
wp option update date_format "j F Y" --path=/var/www/html --allow-root
wp option update time_format "H:i" --path=/var/www/html --allow-root
wp option update start_of_week "1" --path=/var/www/html --allow-root

echo "==> Done"
echo "Site:    http://localhost:8080"
echo "Admin:   http://localhost:8080/wp-admin"
echo "User:    admin"
echo "Pass:    admin"
