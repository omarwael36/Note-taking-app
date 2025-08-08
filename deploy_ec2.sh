#!/bin/bash

# Note Taking App - EC2 Deployment Script
# Run this script on your RHEL 9 EC2 instance

set -e  # Exit on any error

echo "🚀 Starting Note Taking App deployment on EC2..."

# Update system packages
echo "📦 Updating system packages..."
sudo dnf update -y

# Install required packages
echo "🔧 Installing Python, Git, and development tools..."
sudo dnf install -y python3 python3-pip python3-devel git curl wget
sudo dnf groupinstall -y "Development Tools"

echo "ℹ️ Skipping MariaDB installation (using SQLite by default)"

# Clone the repository
echo "📥 Cloning Note Taking App repository..."
cd /home/ec2-user
git clone https://github.com/omarwael36/Note-taking-app.git
cd Note-taking-app

# Create virtual environment
echo "🐍 Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install Flask Flask-SQLAlchemy python-dotenv gunicorn

echo "⚙️ Creating production environment configuration..."
cat > .env << EOF
# Flask Configuration
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
FLASK_CONFIG=production

# Database Configuration (SQLite default)
# DATABASE_URL=sqlite:////home/ec2-user/Note-taking-app/app.db

# Server Configuration
PORT=80
EOF

echo "ℹ️ Skipping DB connectivity test (SQLite)"

# Initialize database tables
echo "🏗️ Creating database tables..."
python3 run.py &
sleep 5
pkill -f "python3 run.py"

# Install and configure gunicorn service
echo "🚀 Setting up production service..."
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
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Set up backup volume and script
echo "💾 Setting up backup system..."
sudo mkdir -p /backup
sudo chown ec2-user:ec2-user /backup

# Copy backup script
cp scripts/backup_db.sh /home/ec2-user/
chmod +x /home/ec2-user/backup_db.sh

:

# Setup daily backup cron job
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ec2-user/backup_db.sh") | crontab -

# Enable and start the service
echo "🎯 Starting Note Taking App service..."
sudo systemctl daemon-reload
sudo systemctl enable noteapp
sudo systemctl start noteapp

# Configure firewall (if firewalld is running)
if systemctl is-active --quiet firewalld; then
    echo "🔥 Configuring firewall..."
    sudo firewall-cmd --permanent --add-port=80/tcp
    sudo firewall-cmd --reload
fi

# Check service status
echo "📊 Checking service status..."
sleep 5
sudo systemctl status noteapp --no-pager

# Test the application
echo "🧪 Testing the application..."
sleep 10
if curl -s http://localhost:80 | grep -q "Note Taking App"; then
    echo "✅ Application is running successfully!"
    echo "🌐 Access your app at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
else
    echo "❌ Application test failed"
    echo "📋 Check logs with: sudo journalctl -u noteapp -f"
fi

echo "🎉 Deployment completed!"
echo ""
echo "📋 Summary:"
echo "- ✅ SQLite configured (default)"
echo "- ✅ Python app deployed with gunicorn"
echo "- ✅ Systemd service 'noteapp' configured"
echo "- ✅ Daily backups scheduled at 2 AM"
echo "- ✅ Application accessible on port 80"
echo ""
echo "🔧 Useful commands:"
echo "- Check app status: sudo systemctl status noteapp"
echo "- View app logs: sudo journalctl -u noteapp -f"
echo "- Restart app: sudo systemctl restart noteapp"
echo "- Run backup manually: /home/ec2-user/backup_db.sh"
echo ""
echo "🌐 Your app should be accessible at:"
echo "http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" 