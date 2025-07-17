# 📝 Note Taking Web App

A modern, responsive web application for creating and managing notes, built with Flask and designed for deployment on AWS EC2 with MariaDB.

## 🚀 Features

- ✅ Clean, responsive web interface
- ✅ Create and store notes with timestamps
- ✅ Real-time note display (newest first)
- ✅ MariaDB/MySQL database support
- ✅ RESTful API endpoints
- ✅ Modern Bootstrap UI with animations
- ✅ Production-ready configuration

## 🏗️ Application Structure

```
Note-taking-app/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── models.py            # Database models
│   ├── routes.py            # Application routes
│   └── templates/
│       ├── base.html        # Base template
│       └── index.html       # Main page
├── config.py                # Configuration settings
├── run.py                   # Application entry point
├── requirements.txt         # Python dependencies
├── env.example              # Environment variables template
└── README.md               # This file
```

## 🛠️ AWS EC2 Deployment Guide

### Prerequisites
- AWS Free Tier Account
- EC2 instance (Red Hat Enterprise Linux 9, t2.micro)
- Security Groups: ports 22 (SSH), 80 (HTTP)
- SSH key pair

### Step 1: Prepare EC2 Instance

```bash
# Connect to your EC2 instance
ssh -i your-key.pem ec2-user@your-ec2-ip

# Update system packages
sudo dnf update -y

# Install Python 3.9+ and development tools
sudo dnf install -y python3 python3-pip python3-devel git
sudo dnf groupinstall -y "Development Tools"
```

### Step 2: Install and Configure MariaDB

```bash
# Install MariaDB
sudo dnf install -y mariadb-server mariadb-devel

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation
sudo mysql_secure_installation
# Follow prompts: set root password, remove anonymous users, etc.

# Create database and user for the app
sudo mysql -u root -p
```

```sql
-- In MySQL prompt:
CREATE DATABASE noteapp;
CREATE USER 'noteapp'@'localhost' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON noteapp.* TO 'noteapp'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 3: Clone and Setup Application

```bash
# Clone the repository
git clone <your-repo-url>
cd Note-taking-app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy and configure environment variables
cp env.example .env
```

Edit `.env` file:
```bash
nano .env
```

```env
# Update with your settings
SECRET_KEY=your-very-secure-secret-key-here
FLASK_CONFIG=production
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=noteapp
MYSQL_PASSWORD=your-secure-password
MYSQL_DATABASE=noteapp
PORT=80
```

### Step 4: Initialize Database

```bash
# Set Flask app
export FLASK_APP=run.py

# Initialize database migrations
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```

### Step 5: Create and Mount Backup Volume

```bash
# Create EBS volume from AWS Console (e.g., 8GB)
# Attach it to your EC2 instance

# Find the new device (usually /dev/xvdf or /dev/nvme1n1)
lsblk

# Format the volume (replace /dev/xvdf with your device)
sudo mkfs -t ext4 /dev/xvdf

# Create mount point
sudo mkdir /backup

# Mount the volume
sudo mount /dev/xvdf /backup

# Add to fstab for permanent mounting
echo '/dev/xvdf /backup ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Set permissions
sudo chown ec2-user:ec2-user /backup
```

### Step 6: Setup Database Backup Script

```bash
# Create backup script
cat << 'EOF' > /home/ec2-user/backup_db.sh
#!/bin/bash
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="noteapp"
DB_USER="noteapp"

# Create backup
mysqldump -u $DB_USER -p$MYSQL_PASSWORD $DB_NAME > $BACKUP_DIR/noteapp_backup_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "noteapp_backup_*.sql" -mtime +7 -delete

echo "Backup completed: noteapp_backup_$DATE.sql"
EOF

chmod +x /home/ec2-user/backup_db.sh

# Add to crontab for daily backups at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ec2-user/backup_db.sh") | crontab -
```

### Step 7: Deploy Application

```bash
# Test the application
python run.py

# For production, use gunicorn
pip install gunicorn

# Create systemd service
sudo tee /etc/systemd/system/noteapp.service > /dev/null << EOF
[Unit]
Description=Note Taking App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/Note-taking-app
Environment=PATH=/home/ec2-user/Note-taking-app/venv/bin
ExecStart=/home/ec2-user/Note-taking-app/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:80 run:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable noteapp
sudo systemctl start noteapp

# Check status
sudo systemctl status noteapp
```

## 🧪 Testing the Application

1. **Web Interface**: Navigate to `http://your-ec2-public-ip`
2. **Create a Note**: Use the form to add a note like "Don't forget to review the IAM policy lecture notes."
3. **Verify Display**: Check that notes appear with timestamps in descending order
4. **API Testing**:
   ```bash
   # Get all notes
   curl http://your-ec2-public-ip/api/notes
   
   # Create a note via API
   curl -X POST -H "Content-Type: application/json" \
        -d '{"content":"API test note"}' \
        http://your-ec2-public-ip/api/notes
   ```

## 🔧 Local Development

```bash
# Clone repository
git clone <repo-url>
cd Note-taking-app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run with SQLite (development)
python run.py

# Access at http://localhost:5000
```

## 📊 Database Schema

### Notes Table
- `id`: Primary key (INTEGER)
- `content`: Note content (TEXT)
- `timestamp`: Creation timestamp (DATETIME)

## 🔒 Security Considerations

- Change default passwords
- Use strong SECRET_KEY
- Configure firewall properly
- Regular security updates
- Enable SSL/TLS in production
- Regular database backups

## 🏆 Project Completion Checklist

- ✅ EC2 instance with RHEL 9
- ✅ Python Flask web application
- ✅ MariaDB database integration
- ✅ Note creation and display functionality
- ✅ Timestamp tracking
- ✅ EBS backup volume mounted at `/backup`
- ✅ Automated backup script
- ✅ Production deployment with systemd
- ✅ Security groups (ports 22, 80)

## 🚨 Troubleshooting

### Common Issues:

1. **Permission Denied on Port 80**:
   ```bash
   sudo setcap 'cap_net_bind_service=+ep' /home/ec2-user/Note-taking-app/venv/bin/python3
   ```

2. **Database Connection Issues**:
   - Check MariaDB service: `sudo systemctl status mariadb`
   - Verify credentials in `.env` file
   - Test connection: `mysql -u noteapp -p noteapp`

3. **Application Won't Start**:
   - Check logs: `sudo journalctl -u noteapp -f`
   - Verify virtual environment activation
   - Check file permissions

4. **Backup Issues**:
   - Verify EBS volume mounting: `df -h`
   - Check backup script permissions: `ls -la backup_db.sh`
   - Test manual backup: `./backup_db.sh`

## 📞 Support

For issues or questions about this deployment, check:
- Application logs: `sudo journalctl -u noteapp`
- Database logs: `sudo journalctl -u mariadb`
- System logs: `sudo journalctl`