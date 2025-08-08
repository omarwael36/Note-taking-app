#!/bin/bash

# Database Backup Script for Note Taking App
# This script creates a backup of the SQLite database file and stores it in /backup

set -e  # Exit on any error

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="${APP_DIR:-/opt/noteapp/src}"
DB_FILE="${DB_FILE:-$APP_DIR/app.db}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_DIR/backup.log"
}

log "Starting database backup..."
if [ ! -f "$DB_FILE" ]; then
    log "ERROR: Database file not found at $DB_FILE"
    exit 1
fi

# Create backup filename
BACKUP_FILE="$BACKUP_DIR/noteapp_backup_$DATE.sqlite"

# Create the backup (copy file) and compress
if cp "$DB_FILE" "$BACKUP_FILE"; then
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
find "$BACKUP_DIR" -name "noteapp_backup_*.sqlite.gz" -mtime +7 -delete

# Count remaining backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "noteapp_backup_*.sqlite.gz" | wc -l)
log "Total backups retained: $BACKUP_COUNT"

log "Backup process completed successfully"

# Optional: Verification for SQLite could be implemented with sqlite3 pragma integrity_check