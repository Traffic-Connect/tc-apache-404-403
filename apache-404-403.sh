#!/bin/bash

# Пути к конфигурационным файлам
JAIL_FILE="/etc/fail2ban/jail.local"
FILTER_FILE="/etc/fail2ban/filter.d/apache-404-403.conf"

# Проверяем, существует ли конфиг Jail
if grep -q "\\[apache-404-403\\]" "$JAIL_FILE"; then
  echo "Конфигурация Jail уже существует в $JAIL_FILE. Пропускаем создание."
else
  echo "Добавляем настройки Jail в $JAIL_FILE..."
  cat <<EOL >> "$JAIL_FILE"

[apache-404-403]
enabled = true
filter = apache-404-403
action = iptables-multiport[name=apache-404-403, port="http,https", protocol=tcp]
logpath = /home/*/web/*/logs/*.log
bantime = 600
findtime = 100
maxretry = 20

EOL
  echo "Настройки Jail добавлены."
fi

# Проверяем, существует ли фильтр
if [ -f "$FILTER_FILE" ]; then
  echo "Фильтр уже существует в $FILTER_FILE. Пропускаем создание."
else
  echo "Создаем фильтр в $FILTER_FILE..."
  cat <<EOL > "$FILTER_FILE"
[Definition]
failregex = ^<HOST>.*" (403|404)
ignoreregex =
EOL
  echo "Фильтр создан."
fi

# Перезапускаем Fail2Ban
echo "Перезапускаем Fail2Ban..."
systemctl restart fail2ban

# Проверяем статус Fail2Ban
echo "Проверяем статус Fail2Ban..."
systemctl status fail2ban

echo "Скрипт выполнен."
