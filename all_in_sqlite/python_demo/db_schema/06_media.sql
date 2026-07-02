-- ============================================================
-- 06_media.sql - 影视 / 音乐 / 游戏 / 娱乐
-- ============================================================

-- 电影
CREATE TABLE IF NOT EXISTS movies (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    original_title  TEXT,
    year            INTEGER,
    director        TEXT,
    cast_list       TEXT,                   -- JSON array
    genre           TEXT,
    duration        INTEGER,                -- 分钟
    country         TEXT,
    language        TEXT,
    imdb_id         TEXT,
    douban_id       TEXT,
    poster_url      TEXT,
    summary         TEXT,
    status          TEXT    DEFAULT 'wish', -- wish/watching/done/abandoned
    watch_date      TEXT,
    watch_count     INTEGER DEFAULT 0,
    personal_rating REAL    CHECK(personal_rating >= 0 AND personal_rating <= 10),
    review          TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 电视剧
CREATE TABLE IF NOT EXISTS tv_shows (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    original_title  TEXT,
    year            INTEGER,
    director        TEXT,
    cast_list       TEXT,                   -- JSON array
    genre           TEXT,
    seasons         INTEGER,
    episodes        INTEGER,
    country         TEXT,
    imdb_id         TEXT,
    douban_id       TEXT,
    poster_url      TEXT,
    summary         TEXT,
    status          TEXT    DEFAULT 'wish', -- wish/watching/done/abandoned
    current_season  INTEGER,
    current_episode INTEGER,
    started_at      TEXT,
    finished_at     TEXT,
    personal_rating REAL    CHECK(personal_rating >= 0 AND personal_rating <= 10),
    review          TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 单集观看记录
CREATE TABLE IF NOT EXISTS episode_log (
    id          TEXT    PRIMARY KEY,
    show_id     TEXT    NOT NULL REFERENCES tv_shows(id),
    season      INTEGER NOT NULL,
    episode     INTEGER NOT NULL,
    watched_at  TEXT    NOT NULL,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 音乐/专辑
CREATE TABLE IF NOT EXISTS music_albums (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    artist          TEXT    NOT NULL,
    year            INTEGER,
    genre           TEXT,
    track_count     INTEGER,
    duration        INTEGER,                -- 秒
    label           TEXT,
    cover_url       TEXT,
    rating          REAL    CHECK(rating >= 0 AND rating <= 10),
    review          TEXT,
    listened_at     TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 歌曲
CREATE TABLE IF NOT EXISTS songs (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    artist          TEXT    NOT NULL,
    album_id        TEXT    REFERENCES music_albums(id),
    duration        INTEGER,
    track_number    INTEGER,
    genre           TEXT,
    lyrics          TEXT,
    play_count      INTEGER DEFAULT 0,
    last_played_at  TEXT,
    is_favorite     INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 游戏
CREATE TABLE IF NOT EXISTS games (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    platform        TEXT,                   -- PC/PS5/Switch/Mobile/...
    developer       TEXT,
    publisher       TEXT,
    release_year    INTEGER,
    genre           TEXT,
    cover_url       TEXT,
    summary         TEXT,
    status          TEXT    DEFAULT 'wish', -- wish/playing/completed/abandoned
    started_at      TEXT,
    completed_at    TEXT,
    playtime        REAL,                   -- 小时
    personal_rating REAL    CHECK(personal_rating >= 0 AND personal_rating <= 10),
    review          TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 动漫
CREATE TABLE IF NOT EXISTS anime (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    original_title  TEXT,
    year            INTEGER,
    studio          TEXT,
    director        TEXT,
    genre           TEXT,
    episodes        INTEGER,
    status          TEXT    DEFAULT 'wish', -- wish/watching/done/abandoned
    personal_rating REAL    CHECK(personal_rating >= 0 AND personal_rating <= 10),
    review          TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 播客
CREATE TABLE IF NOT EXISTS podcasts (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    host            TEXT,
    feed_url        TEXT,
    website_url     TEXT,
    genre           TEXT,
    description     TEXT,
    cover_url       TEXT,
    is_subscribed   INTEGER DEFAULT 1,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS podcast_episodes (
    id              TEXT    PRIMARY KEY,
    podcast_id      TEXT    NOT NULL REFERENCES podcasts(id),
    title           TEXT    NOT NULL,
    duration        INTEGER,
    published_at    TEXT,
    played_at       TEXT,
    is_played       INTEGER DEFAULT 0,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
