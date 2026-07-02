-- ============================================================
-- 08_travel.sql - 旅行 / 地点 / 足迹
-- ============================================================

-- 地点收藏/兴趣点
CREATE TABLE IF NOT EXISTS places (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    location_id     TEXT    REFERENCES locations(id),
    category        TEXT,                   -- restaurant/cafe/scenic_spot/museum/hotel/...
    rating          REAL    CHECK(rating >= 0 AND rating <= 10),
    notes           TEXT,
    price_level     INTEGER,                -- 1-5
    website         TEXT,
    phone           TEXT,
    opening_hours   TEXT,                   -- JSON
    is_visited      INTEGER DEFAULT 0,
    wish_reason     TEXT,                   -- 想去的原因
    visit_count     INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 旅行
CREATE TABLE IF NOT EXISTS trips (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    description     TEXT,
    start_date      TEXT    NOT NULL,
    end_date        TEXT,
    trip_type       TEXT,                   -- solo/family/friends/business
    transportation  TEXT,                   -- JSON: 交通方式列表
    budget          REAL,
    currency        TEXT    DEFAULT 'CNY',
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 旅行目的地（多站）
CREATE TABLE IF NOT EXISTS trip_destinations (
    id          TEXT    PRIMARY KEY,
    trip_id     TEXT    NOT NULL REFERENCES trips(id),
    place_id    TEXT    REFERENCES places(id),
    location_id TEXT    REFERENCES locations(id),
    name        TEXT    NOT NULL,
    arrival_at  TEXT,
    departure_at TEXT,
    day_number  INTEGER,                   -- 第几天
    notes       TEXT,
    sort_order  INTEGER DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 签到/足迹
CREATE TABLE IF NOT EXISTS checkins (
    id          TEXT    PRIMARY KEY,
    place_id    TEXT    REFERENCES places(id),
    location_id TEXT    REFERENCES locations(id),
    datetime    TEXT    NOT NULL,
    activity    TEXT,                       -- 正在做什么
    mood        TEXT,
    is_public   INTEGER DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 护照/签证
CREATE TABLE IF NOT EXISTS passports (
    id              TEXT    PRIMARY KEY,
    country         TEXT    NOT NULL,
    passport_number TEXT,
    issued_at       TEXT,
    expiration_at   TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 签证记录
CREATE TABLE IF NOT EXISTS visas (
    id              TEXT    PRIMARY KEY,
    passport_id     TEXT    REFERENCES passports(id),
    country         TEXT    NOT NULL,
    type            TEXT,                   -- tourist/work/student/transit
    entry_count     TEXT,                   -- single/multiple
    issued_at       TEXT,
    expiration_at   TEXT,
    duration_days   INTEGER,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 住宿记录
CREATE TABLE IF NOT EXISTS accommodations (
    id          TEXT    PRIMARY KEY,
    trip_id     TEXT    REFERENCES trips(id),
    place_id    TEXT    REFERENCES places(id),
    name        TEXT    NOT NULL,
    type        TEXT,                       -- hotel/hostel/airbnb/host/...
    checkin_at  TEXT,
    checkout_at TEXT,
    cost        REAL,
    rating      REAL    CHECK(rating >= 0 AND rating <= 10),
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
