#!/bin/bash

# Настройки
TARGET="/home/fedorovdv/"
REMOTE_USER="fedorovdv"
REMOTE_HOST="192.168.31.176"
REMOTE_DIR="/tmp/backups"

echo "=== Получение списка резервных копий ==="

mapfile -t BACKUPS < <(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -1 ${REMOTE_DIR}")

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "Доступных резервных копий не найдено!"
    exit 1
fi

echo "Выберите номер копии для восстановления:"
for i in "${!BACKUPS[@]}"; do
    echo "[$i] ${BACKUPS[$i]}"
done

read -p "Введите номер: " CHOICE
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -ge "${#BACKUPS[@]}" ]; then
    echo "Неверный выбор!"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$CHOICE]}"
echo "Выбрана копия: $SELECTED_BACKUP"
read -p "Внимание! Данные в $TARGET будут перезаписаны. Продолжить? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Отмена операции."
    exit 0
fi

echo "=== Старт восстановления ==="
# Опция --delete удалит новые файлы, которых не было на момент создания копии
rsync -azv --delete "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${SELECTED_BACKUP}/" "$TARGET"

if [ $? -eq 0 ]; then
    echo "Восстановление успешно завершено!"
else
    echo "Произошла ошибка при восстановлении!"
fi
