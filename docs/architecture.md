# Architecture Overview

## Service Architecture

```mermaid
graph TB
    subgraph "Docker Host"
        subgraph "app-network"
            Web[Web Service<br/>Flask App<br/>Port: 5000]
            DB[DB Service<br/>MySQL 8.0<br/>Port: 3306]
        end
        
        subgraph "Volumes"
            Vol[mysql_data<br/>Persistent Storage]
        end
        
        subgraph "Host Ports"
            Port3000[Host:3000]
            Port3306[Host:3306]
        end
    end
    
    User[User Browser] --> Port3000
    Port3000 --> Web
    Web --> DB
    DB --> Vol
    Port3306 -.-> DB
    
    classDef service fill:#e1f5fe
    classDef storage fill:#f3e5f5
    classDef network fill:#e8f5e8
    
    class Web,DB service
    class Vol storage
    class Port3000,Port3306 network
```

## Data Flow

1. **User Request** → Host Port 3000
2. **Docker Network** → Web Service (Flask)
3. **Database Query** → MySQL Service
4. **Data Storage** → Persistent Volume
5. **Response** → User Browser

## Health Check Flow

```mermaid
sequenceDiagram
    participant DC as Docker Compose
    participant Web as Web Service
    participant DB as MySQL Service
    
    DC->>DB: Start MySQL
    DB->>DB: Initialize Database
    DB->>DC: Health Check OK
    DC->>Web: Start Flask App
    Web->>DB: Test Connection
    DB->>Web: Connection OK
    Web->>DC: Health Check OK
    DC->>DC: All Services Ready
```

## Security Boundaries

- **Network Isolation**: Services communicate via Docker network
- **Non-root User**: Web service runs as `appuser`
- **Environment Variables**: Secrets managed via `.env` file
- **Database Access**: Limited MySQL user privileges
