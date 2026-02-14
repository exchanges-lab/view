# 📊 View — 加密货币图表平台

自建的实时加密货币数据采集与可视化平台，适用于 **Binance USDS-M 永续合约**。结合高性能 Rust 后端与专业图表前端，提供机构级市场数据工具。

这个项目主要是我自用的，实在没太多精力维护。我也不擅长前端，前端代码可能不太规范。欢迎大家发起 Pull Request 和 Issue！

如您所见，这并不是一个简单的一键启动的傻瓜工程，也不是面向小白的玩具项目。请原谅我没有时间也没有能力将其简单化。最简单的部署方式就是让 **Claude Opus 4.6** 研究完整个项目，然后让它来指导你启动。

如果后端部署实在太过困难，您可以暂时直接使用我的公开后端 API 端口：`api-view.cathiefish.org`，这样您只需将前端部署到 Cloudflare Pages 即可。注意该端口仅保证提供 **BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT, XRPUSDT, SUIUSDT** 的数据。请参阅下方[部署](#-部署)章节了解如何配置。

![tv-1](https://img.cathiefish.art/ns/tv-1.png)
![tv-2](https://img.cathiefish.art/ns/tv-2.png)
![tv-3](https://img.cathiefish.art/ns/tv-3.png)
![tv-3](https://img.cathiefish.art/ns/tv-4.png)

## ✨ 功能

### 数据采集与存储
- [x] **实时 WebSocket 推流** — 从 Binance 合并流实时接收 1 分钟 K 线数据，支持自动重连和缺口回补
- [x] **三级历史数据同步** — 月度 ZIP → 每日 ZIP → REST API，从 [Binance 数据归档](https://data.binance.vision/) 尽可能快速回补
- [x] **TimescaleDB 时序存储** — Hypertable 优化，支持 `time_bucket` 聚合，覆盖 8 个时间周期（1m, 5m, 15m, 1h, 4h, 1D, 1W, 1M）
- [x] **代理池支持** — 最多 100 个并发代理客户端，用于高吞吐量并行下载
- [ ] **Binance 现货支持** — 现货市场数据采集，使用 `.P` 后缀区分合约与现货
- [ ] **MCP 支持** — Model Context Protocol 集成

### 图表与可视化
- [x] **专业图表引擎** — 完整的指标和画图工具支持
- [x] **自定义指标** — 净成交量（NV-C）和累积成交量差（CVD-C）
- [x] **多图表布局** — 单图、垂直分割、水平分割、1 左 + 2 右布局，分隔线可拖动
- [x] **图表保存/加载** — 通过内置 `save_load_adapter` 实现保存/加载（元数据存 localStorage，图表内容存后端 API），支持自动保存
- [x] **深色/浅色主题** — 主题切换同步到图表组件和 UI

### 自选列表与交互
- [x] **实时自选列表侧栏** — 实时价格、24 小时涨跌幅、拖拽排序
- [x] **多自定义列表** — 创建和管理多个自选列表
- [ ] **前端品种管理** — 从前端 UI 添加/移除追踪品种（目前 `TRACKED_SYMBOL` 仅通过后端 `.env` 文件控制）

### 安全与部署
- [x] **Google OAuth 保护** — 邮箱白名单访问控制，144 小时会话持久化
- [x] **Docker 就绪** — 多阶段构建，Docker Compose 共享网络
- [ ] **Google Firebase 集成** — 通过 Firebase 连接后端 API，实现托管认证与托管部署

## 📁 项目结构

```
view/
├── backend/                          # Rust 数据引擎 & API 服务
│   ├── src/
│   │   ├── main.rs                   # Axum HTTP 服务启动
│   │   ├── binance_collector.rs      # WebSocket 实时采集 + REST 同步
│   │   ├── historical_downloader.rs  # Binance 数据归档 (ZIP) 下载器
│   │   ├── database.rs              # TimescaleDB 操作与聚合
│   │   ├── scheduler.rs            # 任务调度与采集器生命周期
│   │   ├── klinechart.rs           # KlineChart REST API 处理
│   │   ├── tradingview.rs          # TradingView UDF API + WebSocket + Canvas
│   │   ├── structs.rs              # 数据类型（CandleData, Interval, WsMessage…）
│   │   ├── error.rs                # 自定义错误类型
│   │   └── lib.rs                  # 公开模块导出
│   ├── tests/
│   │   ├── connection_test.rs       # 数据库连接测试
│   │   ├── database_test.rs         # CRUD 与查询测试
│   │   ├── scheduler_test.rs        # 调度器命令与生命周期测试
│   │   ├── sync_test.rs             # 单品种同步测试
│   │   └── sync_full_history_test.rs
│   ├── examples/
│   │   ├── sync_all.rs              # 同步所有品种（标准模式）
│   │   ├── sync_all_fast.rs         # 同步所有品种（代理池并行）
│   │   └── sql.txt                  # TimescaleDB 建表 SQL
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── frontend/                         # 图表库前端
│   ├── index.html                    # 主应用（图表 + 自选列表 + 布局）
│   ├── login.html                    # Google OAuth 登录页
│   ├── auth.js                       # AuthGuard — 会话管理
│   ├── auth-config.js                # OAuth 与 API 配置
│   ├── charting_library/             # 图表库资源
│   ├── datafeeds/                    # UDF 数据源适配器
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── references/                       # Git 子模块
    ├── binance-rust/                 # Binance 连接器 SDK
    └── library/                      # 图表库源码
```

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| **后端** | Rust, Axum, sqlx, tokio, tokio-tungstenite |
| **数据库** | PostgreSQL + TimescaleDB |
| **前端** | Charting Library v29.4, Vanilla JS |
| **认证** | Google Identity Services (OAuth) |
| **部署** | Docker, Nginx, Docker Compose |

## 🚀 部署

对于第一次接触 Nginx Proxy Manager、TimescaleDB、PgAdmin、Docker 或 Cloudflare 的用户，最简单的部署方式就是让 **Claude Opus 4.6** 研究这个项目，然后让它一步步指导你部署。如果持续失败，请在本仓库提交 Issue。

### 方案一：完全自建部署

在自己的服务器上部署全套服务，使用 Docker 和 Nginx Proxy Manager 作为反向代理。

> [!NOTE]
> 如果不清楚以下任何步骤，请咨询 **Claude Opus 4.6**，它可以详细指导你完成每一步。

#### 网络架构

```
┌─────────────────── Docker 网络: cycle ──────────────────────┐
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
      公网域名
  view.yourdomain.com
```

所有容器**必须**在同一个 Docker 网络 `cycle` 中运行，这样才能通过容器名互相通信。只有**前端**需要通过 Nginx Proxy Manager 暴露到公网 —— 后端（端口 `3000`）由前端容器通过 Docker 内部 DNS 访问。

---

#### 第一步：创建 Docker 网络

```bash
docker network create cycle
```

---

#### 第二步：数据库部署（TimescaleDB）

为 TimescaleDB 创建 `docker-compose.yml`，加入 `cycle` 网络：

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

然后使用 [backend/examples/sql.txt](backend/examples/sql.txt) 中的 SQL 初始化数据库：

```bash
docker exec -i timescaledb psql -U quant -d crypto_database < backend/examples/sql.txt
```

> [!TIP]
> 建议同时部署 **PgAdmin** 用于数据库管理。详见[这篇教程](https://n8n.cathiefish.art/n8n-instances-twitter-ai-%E5%88%86%E6%9E%90%E7%9B%91%E6%8E%A7-5b706bb444d7)。新手建议直接让 **Claude Opus 4.6** 来指导。

#### 第三步：部署后端

**1. 配置 `.env`**

```bash
cd backend
cp .env.example .env
```

编辑 `backend/.env`：

```env
RUST_LOG="INFO,binance_sdk::common::utils=off,binance_sdk::common::websocket=off"

DATABASE_URL="postgres://quant:your_secure_password@timescaledb:5432/crypto_database"

TRACKED_SYMBOL=[BTCUSDT,ETHUSDT,BNBUSDT,SOLUSDT,XRPUSDT]

# 代理设置（可选 — 留空则直连）
PROXY_HOST=dc.your-proxy-provider.com
PROXY_USERNAME=your_username
PROXY_PASSWORD=your_password
PROXY_PROTOCOL=https
PROXY_PORT_START=10000
PROXY_PORT_END=10099
```

> [!NOTE]
> `DATABASE_URL` 使用容器名 `timescaledb` 作为主机名 —— 因为两个容器都在 `cycle` 网络中。也可以使用数据库容器的绝对 IP（通过 `docker inspect timescaledb --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'` 查询）。确保数据库容器也在 `cycle` 网络中。`TRACKED_SYMBOL` 目前仅支持 **USDS-M 永续合约（Swap）**，不支持现货。

> [!WARNING]
> **强烈建议配置代理。** 后端需要从 [Binance 数据归档](https://data.binance.vision/) 下载所有追踪品种的历史数据。使用多端口代理池（如 100 个并发连接）。**不使用代理的话，同步可能需要几天时间。** 如果 `PROXY_HOST` 留空，后端将使用单一直连。

**2. 构建并运行**

```bash
docker build -t backend .
docker compose up -d
```

---

#### 第四步：部署前端

构建前端容器之前，需要先配置认证和 API 连接。

**1. 配置 `auth-config.js`**

前端在 Docker 网络内部运行，通过**容器名**访问后端：

```js
window.API_CONFIG = { baseUrl: 'http://backend:3000' };

const AUTH_CONFIG = {
    clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
    onSuccess: (user) => { console.log('Auth successful:', user.email); },
    onError: (error) => { console.error('Auth error:', error); }
};
window.AUTH_CONFIG = AUTH_CONFIG;
window.ALLOWED_EMAILS = ['your-email@gmail.com'];
```

将 `clientId` 替换为你从 GCP Console 获取的 Google OAuth Client ID，将 `ALLOWED_EMAILS` 替换为你的邮箱白名单。

查询后端容器 IP（调试用）：

```bash
$ docker inspect backend --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
172.18.0.3
```

> [!IMPORTANT]
> Google OAuth 需要从 GCP Console 获取 Client ID。教程待补充。

**3. 构建并运行**

```bash
cd frontend
docker build -t frontend .
docker compose up -d
```

> [!WARNING]
> 前端和后端容器**必须**在同一个 Docker 网络（`cycle`）中。两个 `docker-compose.yml` 文件已通过 `networks: cycle: external: true` 配置好。

---

#### 第五步：Nginx Proxy Manager

Nginx Proxy Manager 也必须在 `cycle` 网络中运行。创建 `docker-compose.yml`：

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
> Nginx Proxy Manager 的详细部署和 Docker 最佳实践，请参阅[这篇教程](https://n8n.cathiefish.art/rsshub-install-f5ad036a4dd9)。新手建议直接让 **Claude Opus 4.6** 来指导。

访问管理面板 `http://你的服务器IP:81`（默认账号：`admin@example.com` / `changeme`）。

**为前端创建 Proxy Host：**

| 域名 | 转发主机名 | 转发端口 | SSL |
|------|-----------|---------|-----|
| `view.yourdomain.com` | `frontend_tv` | `80` | ✅ Let's Encrypt |

> [!TIP]
> "转发主机名"使用的是**容器名**（不是 IP），因为所有容器共享 `cycle` 网络。后端**不需要**公网代理 —— 前端通过 Docker 内部 DNS（`http://backend:3000`）访问。

部署完成后，即可通过 `https://view.yourdomain.com` 访问。

---

### 方案二：后端自建 + 前端部署到 Cloudflare Pages

在**方案一**的基础上，额外将后端 API 暴露到公网，并将前端部署到 Cloudflare Pages，而不是自建托管。

> [!NOTE]
> 如果不清楚以下步骤，请咨询 **Claude Opus 4.6** —— 这是很简单的操作。

> [!CAUTION]
> Cloudflare Pages 项目名和自定义域名中**不要**包含 "tradingview"。TradingView 会主动维权，你的部署**会被下架**。使用中性名称如 `view`、`chart`、`crypto-dash`。

#### 第一步：后端 + 数据库

完成**方案一的第一至三步**（创建 `cycle` 网络、部署 TimescaleDB、部署后端）。

#### 第二步：通过 Nginx Proxy Manager 暴露后端 API

由于前端将从 Cloudflare 提供服务（在 Docker 网络外部），后端 API 必须可以从公网访问。在 Nginx Proxy Manager 中添加一个 **Proxy Host**：

| 域名 | 转发主机名 | 转发端口 | SSL |
|------|-----------|---------|-----|
| `api.yourdomain.com` | `backend` | `3000` | ✅ Let's Encrypt |

> [!IMPORTANT]
> 为此 Proxy Host 启用 **Websockets Support** —— 实时 K 线推送需要 WebSocket。

#### 第三步：部署到 Cloudflare Pages

1. Fork 或 Clone 本仓库到你自己的 GitHub 账号
2. 进入 [Cloudflare 控制台](https://dash.cloudflare.com/) → **Workers & Pages** → **创建**
3. 选择 **Pages** → **连接到 Git**
4. 授权 Cloudflare 访问你的 GitHub 账号，选择仓库
5. 配置构建设置：

| 设置 | 值 |
|------|---|
| 生产分支 | `main` |
| 构建命令 | `sh build.sh` |
| 构建输出目录 | `frontend` |

6. 添加**环境变量**（设置 → 环境变量）：

| 变量 | 值 | 说明 |
|------|---|------|
| `API_BASE_URL` | `https://api.yourdomain.com` | 第二步的公网后端 API 地址 |
| `GOOGLE_CLIENT_ID` | `YOUR_CLIENT_ID.apps.googleusercontent.com` | 从 GCP Console 获取的 Google OAuth Client ID |
| `ALLOWED_EMAILS` | `alice@gmail.com,bob@gmail.com` | 逗号分隔的邮箱白名单 |

7. 点击 **保存并部署**

> [!NOTE]
> `build.sh` 脚本会在构建时从环境变量生成 `auth-config.js`。仓库中不存储任何敏感信息 —— 所有凭据通过 Cloudflare 环境变量面板配置。

Cloudflare 会分配一个 `*.pages.dev` 域名。你可以在 **Pages** → **自定义域** 中添加自定义域名。

---

## 📜 许可证

MIT


Generated By Claude Opus 4.6
