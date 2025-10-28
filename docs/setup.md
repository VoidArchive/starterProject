**Linux:**
```bash
docker run -d --name bazi-database \
  -e POSTGRES_USER=bazi \
  -e POSTGRES_PASSWORD=bazigar \
  -e POSTGRES_DB=bazi \
  -p 5433:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:18
```

#### Option B: Using Native PostgreSQL

Create a new database:
```bash
# Linux/macOS
sudo -u postgres psql -c "CREATE DATABASE bazi;"
sudo -u postgres psql -c "CREATE USER bazi WITH PASSWORD 'bazigar';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bazi TO bazi;"

# Windows (PowerShell as Administrator)
psql -U postgres -c "CREATE DATABASE bazi;"
psql -U postgres -c "CREATE USER bazi WITH PASSWORD 'bazigar';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE bazi TO bazi;"
```

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` with the appropriate `DATABASE_URL` for your setup:

**Docker on Linux:**
```env
DATABASE_URL=postgresql://bazi:bazigar@172.17.0.1:5433/bazi?sslmode=disable
```
**Native PostgreSQL (All Platforms):**
```env
DATABASE_URL=postgresql://bazi:bazigar@127.0.0.1:5432/bazi?sslmode=disable
```

> **Note**: If using native PostgreSQL, change port from `5433` to `5432` unless you configured a custom port.

