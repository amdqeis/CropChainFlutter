#!/bin/sh
set -eu
if [ "$#" -ne 1 ]; then
  echo "Usage: scripts/restore.sh backups/cropchain-<timestamp>.dump" >&2
  exit 2
fi
docker compose -f docker-compose.prod.yml exec -T db pg_restore \
  --clean --if-exists --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$1"
