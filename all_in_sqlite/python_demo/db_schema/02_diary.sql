-- ============================================================
-- 02_diary.sql - 日记 / 情绪 / 感恩日记
-- ============================================================

-- 日记条目
CREATE TABLE IF NOT EXISTS diary_entries (
    id              TEXT    PRIMARY KEY,
    title           TEXT,
    content         TEXT    NOT NULL,
    entry_date      TEXT    NOT NULL,       -- 日记日期
    entry_time      TEXT,                   -- 具体时间
    is_draft        INTEGER DEFAULT 0,
    weather         TEXT,                   -- 天气
    temperature     REAL,                   -- 温度(℃)
    location_id     TEXT    REFERENCES locations(id),
    mood_score      INTEGER,               -- 心情分 1-10
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 情绪追踪（可独立于日记）
CREATE TABLE IF NOT EXISTS mood_log (
    id          TEXT    PRIMARY KEY,
    log_date    TEXT    NOT NULL,
    log_time    TEXT,
    mood        TEXT    NOT NULL,           -- happy/sad/angry/anxious/...
    score       INTEGER NOT NULL CHECK(score >= 1 AND score <= 10),
    note        TEXT,
    triggers    TEXT,                       -- JSON array of trigger events
    location_id TEXT    REFERENCES locations(id),
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 感恩日记
CREATE TABLE IF NOT EXISTS gratitude_log (
    id          TEXT    PRIMARY KEY,
    log_date    TEXT    NOT NULL,
    content     TEXT    NOT NULL,
    category    TEXT,                       -- family/health/work/...
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
