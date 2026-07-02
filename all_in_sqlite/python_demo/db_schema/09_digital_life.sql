-- ============================================================
-- 09_digital_life.sql - 数字生活 / 账号 / 设备 / 订阅
-- ============================================================

-- 账号密码（重要：加密存储）
CREATE TABLE IF NOT EXISTS credentials (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,       -- 网站/服务名
    url             TEXT,
    username        TEXT,
    email           TEXT,
    password_enc    TEXT,                   -- AES 加密后的密码
    totp_secret     TEXT,                   -- 2FA 密钥（加密）
    category        TEXT,                   -- social/banking/work/...
    strength        INTEGER,                -- 密码强度 1-4
    notes           TEXT,
    is_favorite     INTEGER DEFAULT 0,
    expire_at       TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 设备
CREATE TABLE IF NOT EXISTS devices (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    brand           TEXT,
    model           TEXT,
    type            TEXT    NOT NULL,       -- phone/tablet/laptop/desktop/tablet/...
    serial_number   TEXT,
    os              TEXT,
    os_version      TEXT,
    purchase_date   TEXT,
    price           REAL,
    warranty_end    TEXT,
    notes           TEXT,
    is_active       INTEGER DEFAULT 1,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 软件许可证
CREATE TABLE IF NOT EXISTS software_licenses (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    version         TEXT,
    license_key     TEXT,                   -- 加密存储
    vendor          TEXT,
    purchase_date   TEXT,
    expiry_date     TEXT,
    seats           INTEGER,
    price           REAL,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 域名
CREATE TABLE IF NOT EXISTS domains (
    id              TEXT    PRIMARY KEY,
    domain_name     TEXT    NOT NULL,
    registrar       TEXT,
    registered_at   TEXT,
    expires_at      TEXT,
    auto_renew      INTEGER DEFAULT 1,
    dns_provider    TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 数字订阅
CREATE TABLE IF NOT EXISTS subscriptions (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,       -- Netflix/Spotify/iCloud/...
    category        TEXT,                   -- streaming/cloud/software/...
    plan            TEXT,                   -- 套餐名
    cost            REAL,
    currency        TEXT    DEFAULT 'CNY',
    billing_cycle   TEXT,                   -- monthly/yearly
    next_billing    TEXT,
    status          TEXT    DEFAULT 'active', -- active/cancelled/paused
    started_at      TEXT,
    cancelled_at    TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- API 密钥
CREATE TABLE IF NOT EXISTS api_keys (
    id          TEXT    PRIMARY KEY,
    service     TEXT    NOT NULL,
    key_enc     TEXT    NOT NULL,           -- 加密存储
    scope       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    expired_at  TEXT
);
