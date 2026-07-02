-- ============================================================
-- 11_events.sql - 日历 / 重大事件 / 纪念日 / 提醒
-- ============================================================

-- 日历事件
CREATE TABLE IF NOT EXISTS calendar_events (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    description     TEXT,
    start_datetime  TEXT    NOT NULL,
    end_datetime    TEXT,
    all_day         INTEGER DEFAULT 0,
    recurrence_rule TEXT,                   -- RRULE (RFC 5545)
    location_id     TEXT    REFERENCES locations(id),
    location_name   TEXT,
    color           TEXT,
    category        TEXT,                   -- personal/work/holiday/birthday/...
    is_private      INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 一生重大事件时间线
CREATE TABLE IF NOT EXISTS life_events (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    date            TEXT    NOT NULL,
    end_date        TEXT,                    -- 跨时间段事件
    category        TEXT,                    -- education/career/family/relocation/...
    description     TEXT,
    significance    INTEGER CHECK(significance >= 1 AND significance <= 10),
    location_id     TEXT    REFERENCES locations(id),
    related_contact_id TEXT REFERENCES contacts(id),
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 纪念日
CREATE TABLE IF NOT EXISTS anniversaries (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,        -- 结婚纪念日/生日/...
    date            TEXT    NOT NULL,        -- MM-dd
    year_based      INTEGER DEFAULT 1,      -- 每年庆祝
    started_year    INTEGER,                 -- 起始年份
    contact_id      TEXT    REFERENCES contacts(id),
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 提醒
CREATE TABLE IF NOT EXISTS reminders (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    note            TEXT,
    remind_at       TEXT    NOT NULL,
    is_recurring    INTEGER DEFAULT 0,
    recurrence_rule TEXT,                   -- RRULE
    is_done         INTEGER DEFAULT 0,
    done_at         TEXT,
    target_id       TEXT,                    -- 关联事项
    target_type     TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
