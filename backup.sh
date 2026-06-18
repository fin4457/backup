#!/bin/bash
SOURCE="/home/fedorovdv/"
REMOTE_USER="fedorovdv"
REMOTE_HOST="192.168.31.176"
REMOTE_DIR="/tmp/backups"
CURRENT_DATE=$(date +%Y-%m-%d_%H-%M-%S)
TARGET_DIR="$REMOTE_DIR/$CURRENT_DATE"

echo "=== Старт резервного копирования ==="

LAST_BACKUP=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -1d ${REMOTE_DIR}/* 2>/dev/null | tail -n 1")

LINK_DEST_OPTS=""
if [ -n "$LAST_BACKUP" ]; then
    LINK_DEST_OPTS="--link-dest=$LAST_BACKUP"
    echo "Найдена прошлая копия: $LAST_BACKUP"
fi

rsync -azv $LINK_DEST_OPTS "$SOURCE" "${REMOTE_USER}@${REMOTE_HOST}:${TARGET_DIR}/"

if [ $? -eq 0 ]; then
    echo "Копирование успешно завершено: $TARGET_DIR"
    # Удаление старых копий (оставляем только 5 последних)
    echo "Очистка старых копий..."
    ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -1d ${REMOTE_DIR}/* | head -n -5 | xargs rm -rf"
    echo "Очистка завершена."
else
    echo "Ошибка при выполнении rsync!"
fi
