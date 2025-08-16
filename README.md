# 📝 Flask Notes Webapp

A simple note-taking web application built with Python Flask and MySQL, containerized with Docker and orchestrated with Docker Compose.

## 🚀 Features

- ✅ Clean, responsive web interface for creating and viewing notes
- ✅ RESTful API endpoints for programmatic access
- ✅ MySQL database with persistent storage
- ✅ Health check endpoint for monitoring
- ✅ Docker containerization with non-root user
- ✅ Docker Compose orchestration with health checks
- ✅ Environment-based configuration

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Web Service   │    │   DB Service    │
│   (Flask App)   │◄──►│    (MySQL)      │
│   Port: 5000    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
   Host Port: 3000         Named Volume
                          (mysql_data)
```

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Homepage with note form and list |
| GET | `/notes` | Get all notes as JSON |
| POST | `/notes` | Create a new note |
| GET | `/healthz` | Health check endpoint |

## 🛠️ Quick Start

### Prerequisites

- Docker and Docker Compose v2
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/omarwael36/Note-taking-app.git
cd Note-taking-app
```

### 2. Configure Environment

```bash
cp env.example .env
```

Edit `.env` file with your preferred settings:

```env
# Flask Configuration
SECRET_KEY=your-very-secure-secret-key-change-this-in-production
FLASK_CONFIG=production

# MySQL Database Configuration
MYSQL_ROOT_PASSWORD=secure-root-password-123
MYSQL_DATABASE=noteapp
MYSQL_USER=noteapp
MYSQL_PASSWORD=secure-user-password-456

# Server Configuration
PORT=5000
HOST=0.0.0.0
```

### 3. Start the Application

```bash
docker-compose up -d
```

This command will:
- Build the Flask application container
- Pull the MySQL 8.0 image
- Create a named volume for database persistence
- Start both services with health checks
- Wait for the database to be ready before starting the web app

### 4. Access the Application

- **Web Interface**: http://localhost:3000
- **Health Check**: http://localhost:3000/healthz

## 🧪 Testing the Application

### Web Interface Testing

1. Open http://localhost:3000 in your browser
2. Enter a note like "Buy milk" and click "Add Note"
3. Verify the note appears in the list with a timestamp

### API Testing

```bash
# Check health
curl http://localhost:3000/healthz

# Get all notes
curl http://localhost:3000/notes

# Create a note via API
curl -X POST -H "Content-Type: application/json" \
     -d '{"content":"API test note"}' \
     http://localhost:3000/notes

# Get notes again to see the new note
curl http://localhost:3000/notes
```

Expected API responses:

```json
# GET /notes
[
  {
    "id": 1,
    "content": "Buy milk",
    "created_at": "2025-01-12T18:00:00Z"
  }
]

# POST /notes (201 Created)
{
  "id": 2,
  "content": "API test note",
  "created_at": "2025-01-12T18:05:00Z"
}

# GET /healthz (200 OK when healthy)
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-01-12T18:00:00Z"
}
```

## 🔧 Development Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Web service only
docker-compose logs -f web

# Database service only
docker-compose logs -f db
```

### Stop the Application

```bash
docker-compose down
```

### Stop and Remove Data

```bash
docker-compose down -v
```

### Rebuild After Code Changes

```bash
docker-compose up --build
```

### Access Database Directly

```bash
docker-compose exec db mysql -u noteapp -p noteapp
```

## 📁 Project Structure

```
Note-taking-app/
├── app/                    # Flask application package
│   ├── __init__.py        # App factory
│   ├── models.py          # Database models
│   ├── routes.py          # Application routes
│   ├── templates/         # HTML templates
│   │   ├── base.html      # Base template
│   │   └── index.html     # Main page
│   └── static/            # CSS/JS assets
├── db/                    # Database initialization
│   └── init/              # SQL init scripts
│       └── 01_create_tables.sql
├── config.py              # Configuration settings
├── run.py                 # Application entry point
├── requirements.txt       # Python dependencies
├── Dockerfile            # Flask app container
├── docker-compose.yml    # Multi-container orchestration
├── .env.example          # Environment variables template
├── .dockerignore         # Docker build exclusions
└── README.md             # This file
```

## 🔒 Security Features

- ✅ Non-root user in Docker container
- ✅ Environment-based configuration (no hardcoded secrets)
- ✅ Input validation for note content
- ✅ MySQL user with limited privileges
- ✅ Network isolation via Docker networks

## 🚨 Troubleshooting

### Application Won't Start

1. **Check service status:**
   ```bash
   docker-compose ps
   ```

2. **View logs:**
   ```bash
   docker-compose logs web
   docker-compose logs db
   ```

3. **Verify environment variables:**
   ```bash
   cat .env
   ```

### Database Connection Issues

1. **Check database health:**
   ```bash
   curl http://localhost:3000/healthz
   ```

2. **Verify database is running:**
   ```bash
   docker-compose exec db mysqladmin ping -h localhost -u root -p
   ```

3. **Reset database:**
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

### Port Already in Use

If port 3000 is already in use, edit `docker-compose.yml`:

```yaml
services:
  web:
    ports:
      - "8080:5000"  # Change host port to 8080
```

### Container Build Issues

1. **Clean build:**
   ```bash
   docker-compose build --no-cache
   ```

2. **Check Docker resources:**
   ```bash
   docker system df
   docker system prune
   ```

## 📊 Database Schema

### Notes Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT AUTO_INCREMENT | Primary key |
| `content` | TEXT | Note content (required) |
| `created_at` | TIMESTAMP | Creation timestamp |

## 🔄 Data Persistence

- Database data is stored in a named Docker volume: `mysql_data`
- Data persists between container restarts
- To completely reset data: `docker-compose down -v`

## 📈 Monitoring

### Health Checks

Both services include health checks:

- **Web service**: Checks `/healthz` endpoint every 30 seconds
- **Database service**: Checks MySQL ping every 10 seconds

### Service Dependencies

The web service waits for the database to be healthy before starting, ensuring proper startup order.

## 🚀 Production Considerations

1. **Use stronger passwords** in production `.env`
2. **Enable SSL/TLS** with a reverse proxy (nginx, Traefik)
3. **Set up log aggregation** for monitoring
4. **Configure backup strategy** for the MySQL volume
5. **Use Docker secrets** instead of environment variables for sensitive data
6. **Set resource limits** in docker-compose.yml

## 📞 Support

For issues or questions:

1. Check the troubleshooting section above
2. View application logs: `docker-compose logs -f`
3. Check service health: `curl http://localhost:3000/healthz`
4. Verify database connectivity: `docker-compose exec db mysql -u noteapp -p`

## 📄 License

This project is open source and available under the [MIT License](LICENSE).