# Deploying the tokenome team server

Turnkey `docker compose` bundle for a single-organization deployment
(spec §10): **Typesense** (the shared index), the **tokenome-server** API, and
**Caddy** terminating TLS. Only ports 80/443 are exposed; Typesense and the
server communicate on the internal network.

> Usage guide (admins, enrolling laptops, sharing, searching, troubleshooting):
> [`docs/team-server-guide.md`](../docs/team-server-guide.md)
>
> Prefer a hosted deploy? See [`railway.md`](railway.md) for Railway
> (no Caddy needed — Railway's edge terminates TLS).

## Prerequisites

- A Linux VM (or any Docker host) you control — self-hosting is the security
  model. 4 GB RAM is plenty to start; see the sizing note in
  `docs/remote-search-spec.md` §11.
- Docker Engine with the compose plugin.
- A DNS name for the server (public for automatic Let's Encrypt TLS, or
  internal — see `Caddyfile` for the `tls internal` option).
- Full-disk/volume encryption on the host (spec §6.5) is the operator's
  responsibility — e.g. LUKS or a cloud provider's encrypted disks.

## First boot

The server ships as a container image, `ghcr.io/tokenome/tokenome-server`,
and this directory ships as the **deploy bundle** attached to each release
at [github.com/tokenome/releases](https://github.com/tokenome/releases)
(the `deploy/` folder there, with the compose file pinned to that release).

```bash
# From the bundle (customers):
cd deploy

# From a checkout (contributors): the same files are in deploy/ here.

cp .env.example .env
$EDITOR .env                 # set TOKENOME_DOMAIN + a strong TYPESENSE_API_KEY

docker compose up -d

# Bootstrap (spec §6.2): creates the identity DB, the JWT signing secret
# (0600, inside the server-data volume), and the first admin user.
docker compose exec server tokenome-server init --admin-name alice
```

`init` prints the admin's **one-time enrollment token**. On the admin's
laptop:

```bash
uv run tokenome remote enroll --server https://<TOKENOME_DOMAIN> --token <token>
```

## Day-2 operations

### Users

```bash
# Add a user (prints their one-time enrollment token — deliver out-of-band)
docker compose exec server tokenome-server create-user bob

# List users and devices; revoke via the admin page or API
docker compose exec server tokenome-server list-users
```

The admin web page lives at `https://<TOKENOME_DOMAIN>/admin` (paste an admin
access token). API docs: `https://<TOKENOME_DOMAIN>/docs`.

### Backups

```bash
docker compose exec server tokenome-server backup /data/backups
docker compose cp server:/data/backups ./backups
```

One tarball: the identity DB (consistent `VACUUM INTO` copy), the JWT
secret file, and the shared index exported as JSON lines *with vectors*
(engine-neutral; restores without re-embedding). Ship it off-box from the
same cron line (rclone/scp). **Run a restore drill before you need one.**
`./backup.sh` still works and adds a Typesense snapshot instead of the
export; the export is the portable form.

### Restore

On a fresh host (or after wiping volumes), from a `tokenome-server backup`
tarball:

```bash
docker compose up -d typesense server          # create containers + volumes
docker compose cp tokenome-backup-<ts>.tar.gz server:/data/
docker compose stop server                     # identity is restored offline
docker compose run --rm server tokenome-server restore /data/tokenome-backup-<ts>.tar.gz
docker compose start server
```

From a legacy `./backup.sh` tarball (Typesense snapshot instead of an export):

```bash
tar -xzf tokenome-backup-<ts>.tar.gz
docker compose up -d typesense server
docker compose stop server typesense
docker compose cp tokenome-backup-<ts>/server.db server:/data/server.db
docker compose cp tokenome-backup-<ts>/jwt.secret server:/data/jwt.secret
docker compose exec typesense sh -c "rm -rf /data/*" || true
docker compose cp tokenome-backup-<ts>/typesense-snapshot/. typesense:/data
docker compose start typesense server
```

Enrolled devices keep working after a restore (their public keys are in the
identity DB, and the JWT secret was preserved).

### Upgrades

```bash
$EDITOR .env                          # TOKENOME_SERVER_VERSION=<new release>
docker compose pull server
docker compose up -d server
```

Every release publishes an image and a bundle under the same version as the
desktop app, and a server advertises the app version it was released with
(`LATEST_CLIENT_VERSION` is baked in; `.env` overrides it).

The API is versioned (`/v1`); check `docs/remote-search-spec.md` §13 for the
compatibility policy. Set `LATEST_CLIENT_VERSION` / `MIN_CLIENT_VERSION` in
`.env` to have `/v1/health` prompt laptops to update.

### Health

```bash
curl -s https://<TOKENOME_DOMAIN>/v1/health | python3 -m json.tool
docker compose ps
docker compose logs -f server
```

## Notes

- **Typesense is intentionally not exposed** to the host or network; every
  query passes through the server's authentication and owner-ACL layer.
- The Typesense image version is pinned to match the client's bundled binary
  (`30.2`); keep them aligned when upgrading.
- The compose project is CI-verified: every push builds this image, runs the
  bootstrap inside it, and validates this compose file; every release builds
  it for amd64 and arm64, smoke-tests both, and publishes the manifest.
