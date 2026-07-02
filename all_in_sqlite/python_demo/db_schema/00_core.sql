-- ============================================================
-- 00_core.sql - 基础核心表
-- ============================================================
-- 所有表共用: id (UUID), created_at, updated_at, deleted_at (软删除)

CREATE TABLE IF NOT EXISTS schema_version (
    version     INTEGER PRIMARY KEY,
    applied_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    description TEXT
);

-- 分类树（可用于任意数据分类）
CREATE TABLE IF NOT EXISTS categories (
    id          TEXT    PRIMARY KEY,
    parent_id   TEXT    REFERENCES categories(id),
    name        TEXT    NOT NULL,
    icon        TEXT,
    color       TEXT,
    sort_order  INTEGER DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 标签（跨域通用）
CREATE TABLE IF NOT EXISTS tags (
    id          TEXT    PRIMARY KEY,
    name        TEXT    NOT NULL UNIQUE,
    color       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 多态标签关联
CREATE TABLE IF NOT EXISTS taggings (
    id          TEXT    PRIMARY KEY,
    tag_id      TEXT    NOT NULL REFERENCES tags(id),
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(tag_id, target_id, target_type)
);

-- 附件/文件（图片、文档等）
CREATE TABLE IF NOT EXISTS attachments (
    id          TEXT    PRIMARY KEY,
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,
    file_name   TEXT    NOT NULL,
    file_data   BLOB,
    file_path   TEXT,                       -- 或存外部路径
    mime_type   TEXT,
    file_size   INTEGER,
    hash_sha256 TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 地理位置（可被任何表引用）
CREATE TABLE IF NOT EXISTS locations (
    id          TEXT    PRIMARY KEY,
    name        TEXT,
    latitude    REAL    NOT NULL,
    longitude   REAL    NOT NULL,
    altitude    REAL,
    address     TEXT,
    country     TEXT,
    province    TEXT,
    city        TEXT,
    district    TEXT,
    place_id    TEXT,                       -- 外部地图服务 ID
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 外部链接/URL
CREATE TABLE IF NOT EXISTS links (
    id          TEXT    PRIMARY KEY,
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,
    url         TEXT    NOT NULL,
    title       TEXT,
    description TEXT,
    favicon_url TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 评分（多态：可用于电影、书籍、音乐等）
CREATE TABLE IF NOT EXISTS ratings (
    id          TEXT    PRIMARY KEY,
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,
    score       REAL    NOT NULL CHECK(score >= 0 AND score <= 10),
    review      TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(target_id, target_type)
);
