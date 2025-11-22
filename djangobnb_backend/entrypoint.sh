#!/bin/bash
set -e

echo "Waiting for database..."

# First, wait for PostgreSQL server to be ready (connect to default 'postgres' database)
echo "Checking if PostgreSQL server is ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
  if python -c "
import os
import psycopg2
try:
    conn = psycopg2.connect(
        dbname='postgres',
        user=os.environ.get('SQL_USER', 'postgresuser'),
        password=os.environ.get('SQL_PASSWORD', 'postgrespassword'),
        host=os.environ.get('SQL_HOST', 'db'),
        port=os.environ.get('SQL_PORT', '5432'),
        connect_timeout=3
    )
    conn.close()
    exit(0)
except Exception as e:
    print(f'Connection error: {e}')
    exit(1)
" 2>&1; then
    echo "PostgreSQL server is up!"
    break
  else
    attempt=$((attempt + 1))
    echo "PostgreSQL server is unavailable - sleeping (attempt $attempt/$max_attempts)"
    sleep 1
  fi
done

if [ $attempt -eq $max_attempts ]; then
  echo "ERROR: Could not connect to PostgreSQL after $max_attempts attempts"
  echo "Checking database container status..."
  exit 1
fi

# Now check if our target database exists, create it if it doesn't
echo "Checking if database exists..."
python -c "
import os
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

db_name = os.environ.get('SQL_DATABASE', 'django_bnb')
try:
    conn = psycopg2.connect(
        dbname='postgres',
        user=os.environ.get('SQL_USER', 'postgresuser'),
        password=os.environ.get('SQL_PASSWORD', 'postgrespassword'),
        host=os.environ.get('SQL_HOST', 'db'),
        port=os.environ.get('SQL_PORT', '5432')
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = conn.cursor()
    cursor.execute('SELECT 1 FROM pg_database WHERE datname=%s', (db_name,))
    exists = cursor.fetchone()
    if not exists:
        cursor.execute(f\"CREATE DATABASE {db_name}\")
        print(f'Database {db_name} created')
    else:
        print(f'Database {db_name} already exists')
    cursor.close()
    conn.close()
except Exception as e:
    print(f'Could not create database: {e}')
" || echo "Database check completed"

echo "Database is ready - executing commands"
python manage.py migrate
python manage.py collectstatic --noinput || echo "Skipping collectstatic (STATIC_ROOT not set)"

exec "$@"