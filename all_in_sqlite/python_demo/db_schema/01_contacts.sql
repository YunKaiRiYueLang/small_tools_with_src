-- ============================================================
-- 01_contacts.sql - 联系人 / 社交关系
-- ============================================================

-- 联系人
CREATE TABLE IF NOT EXISTS contacts (
    id              TEXT    PRIMARY KEY,
    display_name    TEXT    NOT NULL,
    first_name      TEXT,
    last_name       TEXT,
    nickname        TEXT,
    relationship    TEXT,                   -- 关系类型: family/friend/colleague/...
    birthday        TEXT,
    anniversary     TEXT,
    gender          TEXT,
    nationality     TEXT,
    notes           TEXT,
    avatar_id       TEXT    REFERENCES attachments(id),
    is_favorite     INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 联系方式（一对多）
CREATE TABLE IF NOT EXISTS contact_methods (
    id          TEXT    PRIMARY KEY,
    contact_id  TEXT    NOT NULL REFERENCES contacts(id),
    type        TEXT    NOT NULL,           -- phone/email/wechat/telegram/...
    value       TEXT    NOT NULL,           -- 号码/地址/用户名
    is_primary  INTEGER DEFAULT 0,
    label       TEXT,                       -- "家庭电话"/"工作邮箱"
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 联系地址
CREATE TABLE IF NOT EXISTS contact_addresses (
    id          TEXT    PRIMARY KEY,
    contact_id  TEXT    NOT NULL REFERENCES contacts(id),
    label       TEXT,                       -- "家"/"公司"
    location_id TEXT    REFERENCES locations(id),
    is_primary  INTEGER DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 社交关系图谱
CREATE TABLE IF NOT EXISTS relationships (
    id              TEXT    PRIMARY KEY,
    contact_id_a    TEXT    NOT NULL REFERENCES contacts(id),
    contact_id_b    TEXT    NOT NULL REFERENCES contacts(id),
    relation_type   TEXT    NOT NULL,       -- spouse/parent/child/sibling/friend/...
    started_at      TEXT,
    ended_at        TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(contact_id_a, contact_id_b, relation_type)
);

-- 联系记录
CREATE TABLE IF NOT EXISTS contact_interactions (
    id          TEXT    PRIMARY KEY,
    contact_id  TEXT    NOT NULL REFERENCES contacts(id),
    type        TEXT    NOT NULL,           -- meet/call/message/gift/...
    datetime    TEXT    NOT NULL,
    summary     TEXT,
    location_id TEXT    REFERENCES locations(id),
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 群组
CREATE TABLE IF NOT EXISTS groups (
    id          TEXT    PRIMARY KEY,
    name        TEXT    NOT NULL,
    description TEXT,
    icon        TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS group_members (
    id          TEXT    PRIMARY KEY,
    group_id    TEXT    NOT NULL REFERENCES groups(id),
    contact_id  TEXT    NOT NULL REFERENCES contacts(id),
    role        TEXT,                       -- member/admin/owner
    joined_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(group_id, contact_id)
);
