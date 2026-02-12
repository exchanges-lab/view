# 📊 View — Crypto chart Platform

[🇨🇳 中文版 README](README_CN.md)

A self-hosted, real-time cryptocurrency data collection and visualization platform for **Binance USDS-M Futures**. Combines a high-performance Rust backend with a professional charting frontend to deliver institutional-grade market data tooling.

This project is primarily built for my own use, and I don't have much bandwidth to maintain it. I'm also not a frontend developer, so the frontend code may not follow best practices. That said, pull requests and issues are very welcome — feel free to open an Issue or submit a Pull Request!

As you can see, this is not a simple one-click-to-deploy project, nor is it a beginner-friendly toy. I simply don't have the time or ability to simplify it further. The easiest way to deploy is to let **Claude Opus 4.6** study the entire project and have it guide you through the setup.

If deploying the backend is too difficult, you can temporarily use my public backend API endpoint: `api-view.cathiefish.org`. This way you only need to deploy the frontend to Cloudflare Pages. Note that this endpoint only guarantees data for **BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT, XRPUSDT, SUIUSDT**. See the [Deployment](#-deployment) section for how to configure this.

![tv-1](https://img.cathiefish.art/ns/tv-1.png)
![tv-2](https://img.cathiefish.art/ns/tv-2.png)
![tv-3](https://img.cathiefish.art/ns/tv-3.png)

## ✨ Features

### Data Collection & Storage
- [x] **Real-time WebSocket streaming** — Live 1-minute K-line data from Binance combined streams, with auto-reconnect and gap backfill
- [x] **3-tier historical sync** — Monthly ZIP → Daily ZIP → REST API, for fastest possible backfill from [Binance Data Archive](https://data.binance.vision/)
- [x] **TimescaleDB time-series storage** — Hypertable-optimized with `time_bucket` aggregation across 8 timeframes (1m, 5m, 15m, 1h, 4h, 1D, 1W, 1M)
- [x] **Proxy pool support** — Up to 100 concurrent proxy clients for high-throughput parallel downloads
- [ ] **Binance Spot support** — Spot market data collection, using `.P` suffix to distinguish Futures from Spot symbols
- [ ] **MCP support** — Model Context Protocol integration

### Charting & Visualization
- [x] **Professional charting engine** — Full indicator and drawing tool support
- [x] **Custom indicators** — Net Volume (NV-C) and Cumulative Volume Delta (CVD-C)
- [x] **Multi-chart layouts** — Single, vertical split, horizontal split, and 1L+2R layouts with draggable dividers
- [x] **Canvas persistence** — Named drawing canvases per symbol, with auto-save every 5 minutes
- [x] **Dark & Light themes** — Full theme toggle synced across widget and UI

### Watchlist & Interaction
- [x] **Live watchlist sidebar** — Real-time price, 24h change tracking, drag-and-drop reordering
- [x] **Multiple custom lists** — Create and manage separate watchlists
- [ ] **Frontend symbol management** — Add/remove tracked symbols from the frontend UI (currently `TRACKED_SYMBOL` is only controlled via the backend `.env` file)

### Security & Deployment
- [x] **Google OAuth protection** — Email whitelist access control with 144-hour session persistence
- [x] **Docker ready** — Multi-stage builds, Docker Compose with shared network
- [ ] **Google Firebase integration** — Connect backend API via Firebase for managed authentication and hosting

## 📁 Project Structure

```
view/
├── backend/                          # Rust data engine & API server
│   ├── src/
│   │   ├── main.rs                   # Axum HTTP server bootstrap
│   │   ├── binance_collector.rs      # WebSocket real-time collection + REST sync
│   │   ├── historical_downloader.rs  # Binance data archive (ZIP) downloader
│   │   ├── database.rs              # TimescaleDB operations & aggregation
│   │   ├── scheduler.rs            # Task coordination & collector lifecycle
│   │   ├── klinechart.rs           # KlineChart REST API handlers
│   │   ├── tradingview.rs          # TradingView UDF API + WebSocket + Canvas
│   │   ├── structs.rs              # Data types (CandleData, Interval, WsMessage…)
│   │   ├── error.rs                # Custom error types
│   │   └── lib.rs                  # Public module exports
│   ├── tests/
│   │   ├── connection_test.rs       # Database connection tests
│   │   ├── database_test.rs         # CRUD & query tests
│   │   ├── scheduler_test.rs        # Scheduler command & lifecycle tests
│   │   ├── sync_test.rs             # Single symbol sync tests
│   │   └── sync_full_history_test.rs
│   ├── examples/
│   │   ├── sync_all.rs              # Sync all symbols (standard)
│   │   ├── sync_all_fast.rs         # Sync all symbols (parallel with proxy pool)
│   │   └── sql.txt                  # Reference SQL for TimescaleDB setup
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── frontend/                         # Charting Library frontend
│   ├── index.html                    # Main app (widget + watchlist + layouts)
│   ├── login.html                    # Google OAuth login page
│   ├── auth.js                       # AuthGuard — session management
│   ├── auth-config.js                # OAuth & API configuration
│   ├── charting_library/             # Charting Library assets
│   ├── datafeeds/                    # UDF datafeed adapter
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── references/                       # Git submodules
    ├── binance-rust/                 # Binance connector SDK
    └── library/                      # Charting Library source
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Rust, Axum, sqlx, tokio, tokio-tungstenite |
| **Database** | PostgreSQL + TimescaleDB |
| **Frontend** | Charting Library v29.4, Vanilla JS |
| **Auth** | Google Identity Services (OAuth) |
| **Deployment** | Docker, Nginx, Docker Compose |

## 🚀 Deployment

For first-time users of Nginx Proxy Manager, TimescaleDB, PgAdmin, Docker, or Cloudflare — the easiest way to deploy is to let **Claude Opus 4.6** study this project and guide you through each step. If you encounter persistent issues, please open an Issue on this repository.

### Option 1: Full Self-Hosted Deployment

Deploy the entire stack on your own server with Docker and Nginx Proxy Manager as the reverse proxy.

> [!NOTE]
> If you are unsure about any of the steps below, ask **Claude Opus 4.6** for guidance — it can walk you through each step in detail.

#### Network Architecture

```
┌─────────────────── Docker Network: cycle ───────────────────┐
│                                                             │
│   ┌──────────────────┐    ┌──────────────┐                  │
│   │ Nginx Proxy Mgr  │    │  TimescaleDB │                  │
│   │    :80 / :443    │    │    :5432     │                  │
│   └────────┬─────────┘    └──────┬───────┘                  │
│            │                     │                          │
│            │                     │                          │
│   ┌────────▼──┐  ┌───────────┐   │                          │
│   │ Frontend  │  │ Backend   │───┘                          │
│   │ :80       │  │ :3000     │                              │
│   │ (nginx)   │  │ (axum)    │                              │
│   └───────────┘  └───────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         ▲
    Public domain
  view.yourdomain.com
```

All containers **must** run on the same Docker network `cycle` so they can communicate by container name. Only the **frontend** needs to be exposed to the public via Nginx Proxy Manager — the backend (port `3000`) is accessed internally by the frontend container through Docker DNS.

---

#### Step 1: Create Docker Network

```bash
docker network create cycle
```

---

#### Step 2: Database Setup (TimescaleDB)

Create a `docker-compose.yml` for TimescaleDB on the `cycle` network:

```yaml
# database/docker-compose.yml
services:
  timescaledb:
    image: timescale/timescaledb:latest-pg16
    container_name: timescaledb
    networks:
      - cycle
    environment:
      - POSTGRES_USER=quant
      - POSTGRES_PASSWORD=your_secure_password
      - POSTGRES_DB=crypto_database
    volumes:
      - timescaledb_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  timescaledb_data:

networks:
  cycle:
    external: true
```

```bash
docker compose up -d
```

Then initialize the schema using the SQL in [backend/examples/sql.txt](backend/examples/sql.txt):

```bash
docker exec -i timescaledb psql -U quant -d crypto_database < backend/examples/sql.txt
```

> [!TIP]
> For database management, consider deploying **PgAdmin** alongside TimescaleDB. See [this guide](https://n8n.cathiefish.art/n8n-instances-twitter-ai-%E5%88%86%E6%9E%90%E7%9B%91%E6%8E%A7-5b706bb444d7) for PgAdmin setup instructions. For beginners, ask **Claude Opus 4.6** to walk you through it.

#### Step 3: Deploy Backend

**1. Configure `.env`**

```bash
cd backend
cp .env.example .env
```

Edit `backend/.env`:

```env
RUST_LOG="INFO,binance_sdk::common::utils=off,binance_sdk::common::websocket=off"

DATABASE_URL="postgres://quant:your_secure_password@timescaledb:5432/crypto_database"

TRACKED_SYMBOL=[BTCUSDT,ETHUSDT,BNBUSDT,SOLUSDT,XRPUSDT]

# Proxy settings (optional — leave empty for direct connection)
PROXY_HOST=dc.your-proxy-provider.com
PROXY_USERNAME=your_username
PROXY_PASSWORD=your_password
PROXY_PROTOCOL=https/http/socks5
PROXY_PORT_START=10000
PROXY_PORT_END=10099
```

> [!NOTE]
> `DATABASE_URL` uses the container name `timescaledb` as the hostname — this works because both containers are on the `cycle` network. You can also use the database container's absolute IP (find it with `docker inspect timescaledb --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'`). Make sure the database container is also on the `cycle` network. `TRACKED_SYMBOL` currently only supports **USDS-M Futures (Swap)**, not Spot.

> [!WARNING]
> **Proxy is strongly recommended.** Historical data sync downloads from [Binance Data Archive](https://data.binance.vision/) for all tracked symbols. With a multi-port proxy pool (e.g. 100 concurrent connections), a full sync completes in hours. **Without a proxy, syncing may take several days.** If `PROXY_HOST` is left empty, the backend falls back to a single direct connection.

**2. Build & Run**

```bash
docker build -t backend .
docker compose up -d
```

---

#### Step 4: Deploy Frontend

Before building the frontend container, you need to configure authentication and API connection.

**1. Configure Google OAuth — `auth-config.js`**

Since the frontend runs inside the Docker network, it accesses the backend via the **container name**:

```js
// Use the backend container name as the hostname (internal Docker DNS)
window.API_CONFIG = { baseUrl: 'http://backend:3000' };

const AUTH_CONFIG = {
    // Replace with your Google OAuth Client ID from GCP Console
    clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
    onSuccess: (user) => { console.log('Auth successful:', user.email); },
    onError: (error) => { console.error('Auth error:', error); }
};
window.AUTH_CONFIG = AUTH_CONFIG;
```

To find the backend container IP (useful for debugging):

```bash
$ docker inspect backend --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
172.18.0.3
```

**2. Configure Email Whitelist — `login.html`**

Add your Google account email to the whitelist:

```js
const allowedEmails = ['your-email@gmail.com'];
```

> [!IMPORTANT]  
> Google OAuth requires a Client ID from GCP Console. Tutorial placeholder — to be added.

**3. Build & Run**

```bash
cd frontend
docker build -t frontend .
docker compose up -d
```

> [!WARNING]
> The frontend and backend containers **must** be on the same Docker network (`cycle`). This is already configured in both `docker-compose.yml` files via `networks: cycle: external: true`.

---

#### Step 5: Nginx Proxy Manager

Nginx Proxy Manager must also run on the `cycle` network. Create a `docker-compose.yml`:

```yaml
# npm/docker-compose.yml
services:
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    networks:
      - cycle
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    volumes:
      - npm_data:/data
      - npm_letsencrypt:/etc/letsencrypt
    restart: unless-stopped

volumes:
  npm_data:
  npm_letsencrypt:

networks:
  cycle:
    external: true
```

```bash
docker compose up -d
```

> [!TIP]
> For detailed Nginx Proxy Manager setup and Docker deployment best practices, see [this guide](https://n8n.cathiefish.art/rsshub-install-f5ad036a4dd9). For beginners, ask **Claude Opus 4.6** to walk you through it.

Access the admin panel at `http://your-server-ip:81` (default: `admin@example.com` / `changeme`).

**Create a Proxy Host for the frontend:**

| Domain | Forward Hostname | Forward Port | SSL |
|--------|-----------------|--------------|-----|
| `view.yourdomain.com` | `frontend_tv` | `80` | ✅ Let's Encrypt |

> [!TIP]
> The "Forward Hostname" uses the **container name** (not IP), which works because all containers share the `cycle` network. The backend does **not** need a public proxy — the frontend accesses it internally via Docker DNS (`http://backend:3000`).

After setup, your platform will be accessible at `https://view.yourdomain.com`.

---

### Option 2: Backend Self-Hosted + Frontend on Cloudflare Pages

Build on top of **Option 1** — keep the same server-side setup (Docker network, TimescaleDB, backend), but additionally expose the backend API to the public internet and deploy the frontend to Cloudflare Pages instead of self-hosting it.

> [!NOTE]
> If you are unsure about any of these steps, ask **Claude Opus 4.6** — this is a straightforward process.

> [!CAUTION]
> **Do NOT** include "tradingview" in your Cloudflare Pages project name or custom domain. TradingView actively enforces their trademark and your deployment **will be taken down**. Use a neutral name like `view`, `chart`, or `crypto-dash`.

#### Step 1: Backend + Database

Complete **Option 1 Steps 1–3** (create `cycle` network, deploy TimescaleDB, deploy backend).

#### Step 2: Expose Backend API via Nginx Proxy Manager

Since the frontend will be served from Cloudflare (outside your Docker network), the backend API must be publicly accessible. Add a **second Proxy Host** in Nginx Proxy Manager:

| Domain | Forward Hostname | Forward Port | SSL |
|--------|-----------------|--------------|-----|
| `api.yourdomain.com` | `backend` | `3000` | ✅ Let's Encrypt |

> [!IMPORTANT]
> Enable **Websockets Support** for this proxy host — required for real-time candle streaming.

#### Step 3: Configure Frontend

Before deploying to Cloudflare, update the config files:

**`auth-config.js`** — point `baseUrl` to the **public backend domain** from Step 2:

```js
window.API_CONFIG = { baseUrl: 'https://api.yourdomain.com' };

const AUTH_CONFIG = {
    clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
    // ...
};
```

**`login.html`** — add your email to the whitelist:

```js
const allowedEmails = ['your-email@gmail.com'];
```

#### Step 4: Deploy to Cloudflare Pages

1. Fork or clone this repository to your own GitHub account
2. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages** → **Create**
3. Select **Pages** → **Connect to Git**
4. Authorize Cloudflare to access your GitHub account and select the repository
5. Configure the build settings:

| Setting | Value |
|---------|-------|
| Production branch | `main` |
| Build command | *(leave empty)* |
| Build output directory | `frontend` |

6. Click **Save and Deploy**

Cloudflare will assign a `*.pages.dev` domain. You can add a custom domain in **Pages** → **Custom domains**.

---

## 📜 License

MIT


Generated By Claude Opus 4.6
