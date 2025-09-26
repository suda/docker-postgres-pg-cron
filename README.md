### docker-postgres-pg-cron

This repository builds Docker images that package PostgreSQL with the pg_cron extension across multiple base OS variants, and publishes multi-arch images for both amd64 and arm64.

#### What you get
- **PostgreSQL + pg_cron**: pg_cron is built/installed and ready to enable per database.
- **Base OS variants**: Alpine (including specific minor versions) and Debian Trixie.
- **Multi-arch**: Images are pushed as a manifest list covering amd64 and arm64; Docker automatically pulls the right image for your platform.

#### Variants (by Dockerfile in this repo)
- `Dockerfile.alpine`
- `Dockerfile.alpine3.21`
- `Dockerfile.alpine3.22`
- `Dockerfile.trixie` (Debian Trixie)

Tag names in your registry may follow a pattern like:
- `postgres-<MAJOR>-alpine`
- `postgres-<MAJOR>-alpine3.21`
- `postgres-<MAJOR>-alpine3.22`
- `postgres-<MAJOR>-trixie`

Replace `<MAJOR>` with the PostgreSQL major version you want (e.g., `16`, `15`). See the GHCR package page for the authoritative list of available tags.

### Quick pull instructions

Images are published to GHCR under `ghcr.io/suda/docker-postgres-pg-cron`.

```bash
# Alpine latest for a major version (example: Postgres 16 on Alpine)
docker pull ghcr.io/suda/docker-postgres-pg-cron:16-alpine

# Specific Alpine base version
docker pull ghcr.io/suda/docker-postgres-pg-cron:16-alpine3.22

# Debian Trixie variant
docker pull ghcr.io/suda/docker-postgres-pg-cron:16-trixie

# Older major versions (examples)
docker pull ghcr.io/suda/docker-postgres-pg-cron:15-alpine
docker pull ghcr.io/suda/docker-postgres-pg-cron:15-trixie
```

Because these are multi-arch images, you do not need to specify architecture; Docker will pull the correct `amd64` or `arm64` image automatically based on your platform.

### Enabling pg_cron in your database

Once the container is running and you are connected to a database, enable the extension:

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

You can then schedule jobs, for example:

```sql
SELECT cron.schedule('nightly-vacuum', '0 3 * * *', $$VACUUM$$);
```

### Example docker run

```bash
docker run -d \
  --name pg-cron \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  ghcr.io/suda/docker-postgres-pg-cron:16-alpine
```

Then connect with your preferred client and enable `pg_cron` as shown above.

### Building locally (optional)

If you want to build locally for testing, you can target a specific Dockerfile:

```bash
# Alpine 3.22 example
docker build -f Dockerfile.alpine3.22 -t local/docker-postgres-pg-cron:postgres-16-alpine3.22 .

# Debian Trixie example
docker build -f Dockerfile.trixie -t local/docker-postgres-pg-cron:postgres-16-trixie .
```

Push and tag according to your registry conventions.


### Troubleshooting

If you see an error like:

```
Jobs must be scheduled from the database configured in cron.database_name
```

set the database `pg_cron` should run against by providing PostgreSQL server args via environment variable when starting the container:

```bash
docker run -d \
  --name pg-cron \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_ARGS="-c cron.database_name=YOUR_DB" \
  -p 5432:5432 \
  ghcr.io/suda/docker-postgres-pg-cron:16-alpine
```

Replace `YOUR_DB` with the target database name. Schedule jobs from that database after enabling `pg_cron`.


