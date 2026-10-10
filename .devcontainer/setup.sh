#!/usr/bin/env bash
# Runs once when the Codespace is created: MySQL client, dependencies, .env, database.
set -euo pipefail
cd "$(dirname "$0")/../review 3"

sudo apt-get update -qq && sudo apt-get install -y -qq default-mysql-client >/dev/null

echo "Waiting for MySQL..."
for i in $(seq 1 60); do
  mysqladmin ping -h db -uroot -pcodespace-only --silent 2>/dev/null && break
  sleep 2
done

npm install --no-audit --no-fund

if [ ! -f .env ]; then
  cp .env.example .env
  sed -i "s/^DB_HOST=.*/DB_HOST=db/" .env
  sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=codespace-only/" .env
  sed -i "s/^JWT_SECRET=.*/JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")/" .env
fi

# Create bank_db with the sample data (the SQL file is used unchanged).
mysql -h db -uroot -pcodespace-only < bank_review2.sql
echo "Database ready."
