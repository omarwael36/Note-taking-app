#!/bin/bash

# Database Backup Script for Note Taking App
# This script creates a backup of the MariaDB database and stores it in /backup

set -e  # Exit on any error

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="${MYSQL_DATABASE:-noteapp}"
DB_USER="${MYSQL_USER:-noteapp}"
DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_DIR/backup.log"
}

log "Starting database backup..."

# Check if MySQL/MariaDB is running
if ! systemctl is-active --quiet mariadb; then
    log "ERROR: MariaDB service is not running"
    exit 1
fi

# Create backup filename
BACKUP_FILE="$BACKUP_DIR/noteapp_backup_$DATE.sql"

# Create the backup
if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$MYSQL_PASSWORD" \
    --single-transaction --routines --triggers "$DB_NAME" > "$BACKUP_FILE"; then
    
    # Compress the backup
    gzip "$BACKUP_FILE"
    BACKUP_FILE="$BACKUP_FILE.gz"
    
    log "Backup completed successfully: $(basename $BACKUP_FILE)"
    log "Backup size: $(du -h $BACKUP_FILE | cut -f1)"
else
    log "ERROR: Backup failed"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Keep only last 7 days of backups
log "Cleaning up old backups (keeping last 7 days)..."
find "$BACKUP_DIR" -name "noteapp_backup_*.sql.gz" -mtime +7 -delete

# Count remaining backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "noteapp_backup_*.sql.gz" | wc -l)
log "Total backups retained: $BACKUP_COUNT"

log "Backup process completed successfully"

# Optional: Test the backup by creating a temporary database
# Uncomment the following lines if you want to verify backup integrity
# 
# TEST_DB="noteapp_test_$$"
# log "Testing backup integrity..."
# mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$MYSQL_PASSWORD" \
#     -e "CREATE DATABASE $TEST_DB"
# zcat "$BACKUP_FILE" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" \
#     -p"$MYSQL_PASSWORD" "$TEST_DB"
# mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$MYSQL_PASSWORD" \
#     -e "DROP DATABASE $TEST_DB"
# log "Backup integrity test passed" 