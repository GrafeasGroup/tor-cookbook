#!/usr/bin/env bash
set -euo pipefail

rsync -avz /var/lib/redis/dump.rdb jokers-storage02:/data/backups/tor/redis-dump.rdb
