-- ============================================================
-- 10_assets.sql - 实物资产 / 物品 / 文档
-- ============================================================

-- 实物物品清单
CREATE TABLE IF NOT EXISTS physical_items (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    category        TEXT,                   -- electronics/furniture/clothing/kitchen/...
    brand           TEXT,
    model           TEXT,
    serial_number   TEXT,
    purchase_date   TEXT,
    purchase_price  REAL,
    current_value   REAL,
    warranty_expire TEXT,
    location        TEXT,                   -- 存放位置（家/办公室/...）
    notes           TEXT,
    photo_id        TEXT    REFERENCES attachments(id),
    is_favorite     INTEGER DEFAULT 0,
    is_gift         INTEGER DEFAULT 0,
    gift_from       TEXT,
    status          TEXT    DEFAULT 'owned', -- owned/sold/lost/donated/broken
    sold_at         TEXT,
    sold_price      REAL,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 重要证件
CREATE TABLE IF NOT EXISTS documents (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    type            TEXT    NOT NULL,       -- id_card/passport/driving_license/diploma/contract/...
    doc_number      TEXT,
    issued_by       TEXT,
    issued_at       TEXT,
    expiration_at   TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 车辆
CREATE TABLE IF NOT EXISTS vehicles (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    brand           TEXT,
    model           TEXT,
    license_plate   TEXT,
    vin             TEXT,
    purchase_date   TEXT,
    purchase_price  REAL,
    mileage         INTEGER,                -- km
    insurance_exp   TEXT,
    inspection_exp  TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 维修/保养记录
CREATE TABLE IF NOT EXISTS maintenance_logs (
    id          TEXT    PRIMARY KEY,
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,            -- vehicles/physical_items
    date        TEXT    NOT NULL,
    type        TEXT,                        -- repair/maintenance/upgrade
    description TEXT,
    cost        REAL,
    provider    TEXT,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
