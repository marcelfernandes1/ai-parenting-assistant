# Database Setup Guide

This guide covers setting up PostgreSQL and Redis for local development.

---

## PostgreSQL Setup

### Installation

#### macOS (Homebrew)
```bash
# Install PostgreSQL
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
```

#### macOS (Postgres.app)
1. Download from https://postgresapp.com/
2. Move to Applications folder
3. Open Postgres.app
4. Click "Initialize" to create a new server

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Windows
1. Download from https://www.postgresql.org/download/windows/
2. Run installer
3. Follow setup wizard
4. Remember the password you set for `postgres` user

### Create Development Database

```bash
# Connect to PostgreSQL as superuser
psql postgres

# Create database
CREATE DATABASE ai_parenting_assistant_dev;

# Create user (optional - for better security)
CREATE USER ai_parenting_user WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ai_parenting_assistant_dev TO ai_parenting_user;

# Exit psql
\q
```

### Update .env File

```bash
# In backend/.env, update DATABASE_URL:
DATABASE_URL=postgresql://ai_parenting_user:your_secure_password@localhost:5432/ai_parenting_assistant_dev

# Or if using default postgres user:
DATABASE_URL=postgresql://postgres:your_postgres_password@localhost:5432/ai_parenting_assistant_dev
```

### Verify Connection

```bash
# Test connection
psql ai_parenting_assistant_dev

# Or test with connection string
psql "postgresql://ai_parenting_user:your_secure_password@localhost:5432/ai_parenting_assistant_dev"
```

### Useful PostgreSQL Commands

```sql
-- List all databases
\l

-- Connect to database
\c ai_parenting_assistant_dev

-- List all tables
\dt

-- Describe table structure
\d table_name

-- Show current database
SELECT current_database();

-- Exit psql
\q
```

---

## Redis Setup

### Installation

#### macOS (Homebrew)
```bash
# Install Redis
brew install redis

# Start Redis service
brew services start redis

# Verify Redis is running
redis-cli ping
# Should return: PONG
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify
redis-cli ping
```

#### Windows
1. Download from https://github.com/microsoftarchive/redis/releases
2. Extract ZIP file
3. Run `redis-server.exe`

**Note:** For Windows, consider using Docker instead (see Docker option below)

### Docker Option (All Platforms)

```bash
# Start Redis container
docker run --name redis-dev -p 6379:6379 -d redis:7-alpine

# Verify
docker exec -it redis-dev redis-cli ping
```

### Update .env File

```bash
# In backend/.env:
REDIS_URL=redis://localhost:6379
```

### Verify Connection

```bash
# Test Redis
redis-cli ping

# Set and get a test value
redis-cli set test "Hello"
redis-cli get test

# Monitor Redis commands (useful for debugging)
redis-cli monitor
```

### Useful Redis Commands

```bash
# Check Redis info
redis-cli info

# Monitor all commands
redis-cli monitor

# Clear all data (use with caution!)
redis-cli FLUSHALL

# Get all keys
redis-cli KEYS '*'
```

---

## Docker Compose Option (Recommended for Development)

Create `docker-compose.yml` in project root for easy setup:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: ai-parenting-postgres
    environment:
      POSTGRES_DB: ai_parenting_assistant_dev
      POSTGRES_USER: ai_parenting_user
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ai_parenting_user -d ai_parenting_assistant_dev"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: ai-parenting-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

### Using Docker Compose

```bash
# Start databases
docker-compose up -d

# Stop databases
docker-compose down

# View logs
docker-compose logs -f

# Reset databases (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

### Update .env for Docker

```bash
# backend/.env
DATABASE_URL=postgresql://ai_parenting_user:dev_password@localhost:5432/ai_parenting_assistant_dev
REDIS_URL=redis://localhost:6379
```

---

## Troubleshooting

### PostgreSQL Connection Issues

**Error: "Connection refused"**
```bash
# Check if PostgreSQL is running
pg_isready

# Start PostgreSQL
brew services start postgresql@15  # macOS
sudo systemctl start postgresql    # Linux
```

**Error: "Role does not exist"**
```bash
# Create the user
psql postgres -c "CREATE USER ai_parenting_user WITH PASSWORD 'your_password';"
```

**Error: "Database does not exist"**
```bash
# Create the database
psql postgres -c "CREATE DATABASE ai_parenting_assistant_dev;"
```

### Redis Connection Issues

**Error: "Could not connect to Redis"**
```bash
# Check if Redis is running
redis-cli ping

# Start Redis
brew services start redis  # macOS
sudo systemctl start redis # Linux
```

### Port Already in Use

**PostgreSQL (port 5432)**
```bash
# Find process using port
lsof -i :5432  # macOS/Linux
netstat -ano | findstr :5432  # Windows

# Kill process or change port in docker-compose.yml
```

**Redis (port 6379)**
```bash
# Find process using port
lsof -i :6379  # macOS/Linux

# Kill process or change port in docker-compose.yml
```

---

## Next Steps

After setting up databases:

1. ✅ PostgreSQL running on port 5432
2. ✅ Redis running on port 6379
3. ✅ .env file updated with connection strings
4. ✅ Connection verified with test commands

You're ready to proceed with Prisma setup!

---

*Last Updated: 2025-10-28*
