##########################################################################
#!/bin/bash
#1)
#Создать файл ssh ключей для github.com в автозапуске
rm -rf /etc/ssh/ssh_config.d/github.com.conf
cat <<EOF >> /etc/ssh/ssh_config.d/github.com.conf
Host github.com
    HostName github.com
    IdentityFile /etc/ssh/ssh_host_rsa_key
EOF

#Права на файл ключей ssh
chmod 600 /etc/ssh/ssh_config.d/github.com.conf
ssh -T git@github.com
##########################################################################

#2)
#Скачать из репозитория https://github.com/
#Установить и подготовить git
yum -y install git
git config --global user.name "Alexey Boltykhov"
git config --global user.email aboltykhov@mail.ru
git config --global core.editor vi
rm -rf /tmp/dz_itog
mkdir dz_itog && cd dz_itog

#Скачать бекап,
#Если не скачивает, проверить название ветки, в моем случае main
git init && git remote add origin git@github.com:aboltykhov/dz_itog.git
git pull origin main && ls -lh
##########################################################################

#3)
#Отключить SElinux, требуется перезагрузка ОС
cd /tmp/dz_itog
./selinux-off.sh

#Если перезагрузка ОС не требуется, перейти в каталог со скриптами
cd /tmp/dz_itog && ls -lh
