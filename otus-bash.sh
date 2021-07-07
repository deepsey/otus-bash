#!/bin/bash

#Устанавливаем mutt 
yum install -y mutt

#Копируем необходимые файлы
cp /vagrant/script.sh /vagrant/access.log /root

#Создаем сервис для запуска скрипта

cat <<'EOF1' | sudo tee /etc/systemd/system/bashpost.service
[Unit]
Description=Bash Script

[Service]
ExecStart=/bin/bash /root/script.sh

[Install]
WantedBy=multi-user.target
EOF1

#Создаем таймер для сервса

cat <<'EOF1' | sudo tee /etc/systemd/system/bashpost.timer
[Unit]
Description=Timer For bashpost service

[Timer]
OnUnitActiveSec=1h

[Install]
WantedBy=multi-user.target
EOF1

#Активируем и запускаем юниты

systemctl daemon-reload
systemctl enable bashpost
systemctl enable bashpost.timer
systemctl start bashpost
systemctl start bashpost.timer
