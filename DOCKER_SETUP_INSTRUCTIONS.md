# Docker Desktop Installation Instructions

Docker installation requires manual steps. Follow these instructions:

---

## Option 1: Install Docker Desktop (GUI - Recommended)

### Step 1: Download Docker Desktop
1. Visit: https://www.docker.com/products/docker-desktop
2. Click "Download for Mac"
3. Choose the correct version:
   - **Apple Silicon (M1/M2/M3)**: Download "Mac with Apple chip"
   - **Intel Mac**: Download "Mac with Intel chip"

### Step 2: Install Docker Desktop
1. Open the downloaded `Docker.dmg` file
2. Drag `Docker.app` to your Applications folder
3. Open Docker Desktop from Applications
4. Accept the license agreement
5. Grant necessary permissions when prompted
6. Wait for Docker to start (you'll see the whale icon in menu bar)

### Step 3: Verify Installation
Open Terminal and run:
```bash
docker --version
docker compose version
```

You should see version numbers for both commands.

---

## Option 2: Install via Homebrew (Command Line)

If you have admin/sudo access:

```bash
# Install Docker Desktop
brew install --cask docker

# Launch Docker Desktop
open -a Docker

# Wait for Docker to start, then verify
docker --version
```

---

## Starting the Databases

Once Docker is installed and running:

### Step 1: Navigate to Project Directory
```bash
cd "/Users/marcelfernandes/Developer/AI Baby Assistant"
```

### Step 2: Start Databases
```bash
docker compose up -d
```

This will start:
- PostgreSQL 15 on port 5432
- Redis 7 on port 6379

### Step 3: Verify Databases are Running
```bash
# Check running containers
docker ps

# You should see two containers:
# - ai-parenting-postgres
# - ai-parenting-redis
```

### Step 4: Test Database Connections

**Test PostgreSQL:**
```bash
docker exec -it ai-parenting-postgres psql -U ai_parenting_user -d ai_parenting_assistant_dev -c "SELECT version();"
```

**Test Redis:**
```bash
docker exec -it ai-parenting-redis redis-cli ping
# Should return: PONG
```

---

## Useful Docker Commands

### Managing Containers
```bash
# Start databases
docker compose up -d

# Stop databases
docker compose down

# View logs
docker compose logs -f

# Restart databases
docker compose restart

# Stop and remove all data (CAUTION: deletes all database data)
docker compose down -v
```

### Monitoring
```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View container logs
docker logs ai-parenting-postgres
docker logs ai-parenting-redis

# View real-time logs
docker logs -f ai-parenting-postgres
```

### Accessing Databases
```bash
# PostgreSQL shell
docker exec -it ai-parenting-postgres psql -U ai_parenting_user -d ai_parenting_assistant_dev

# Redis CLI
docker exec -it ai-parenting-redis redis-cli
```

---

## Troubleshooting

### Docker Desktop Won't Start
1. Quit Docker Desktop completely
2. Restart your Mac
3. Open Docker Desktop again
4. Wait for initialization (can take 2-3 minutes)

### "Cannot connect to Docker daemon"
- Ensure Docker Desktop is running (check menu bar for whale icon)
- Wait a few seconds for Docker to fully start
- Try: `docker ps` to test connection

### Port Already in Use
If ports 5432 or 6379 are in use:

**Find what's using the port:**
```bash
lsof -i :5432  # PostgreSQL
lsof -i :6379  # Redis
```

**Stop the conflicting service:**
```bash
# If Homebrew PostgreSQL is running
brew services stop postgresql@15

# If Homebrew Redis is running
brew services stop redis
```

### Containers Won't Start
```bash
# View detailed error logs
docker compose logs

# Remove containers and try again
docker compose down
docker compose up -d
```

---

## Alternative: Use Managed Services (No Docker Required)

If you prefer not to use Docker:

### PostgreSQL Alternatives
1. **Neon** (Free tier): https://neon.tech
2. **Supabase** (Free tier): https://supabase.com
3. **Railway** (Free trial): https://railway.app

### Redis Alternatives
1. **Upstash** (Free tier): https://upstash.com
2. **Redis Cloud** (Free tier): https://redis.com/try-free

Just update `backend/.env` with the connection strings provided by these services.

---

## Next Steps After Installation

Once Docker is running and databases are started:

1. ✅ Verify databases: `docker ps`
2. ✅ Test connections (see commands above)
3. 🚀 **Ready for Phase 1 development!**

Let me know when Docker is installed and running, and I'll help you start the databases!

---

*Created: 2025-10-28*
