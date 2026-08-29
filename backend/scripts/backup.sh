#!/bin/sh
set -eu
mkdir -p backups
stamp=$(date -u +%Y%m%dT%H%M%SZ)
docker compose -f docker-compose.prod.yml exec -T db pg_dump \
  -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc > "backups/cropchain-$stamp.dump"
find backups -type f -name 'cropchain-*.dump' -mtime +14 -delete
