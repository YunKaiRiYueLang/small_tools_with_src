-- ============================================================
-- 05_knowledge.sql - 知识 / 笔记 / 阅读 / 学习
-- ============================================================

-- 笔记（支持富文本/Markdown）
CREATE TABLE IF NOT EXISTS notes (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    content         TEXT,                   -- Markdown / HTML
    preview         TEXT,                   -- 纯文本预览
    notebook        TEXT,                   -- 笔记本分组
    is_favorite     INTEGER DEFAULT 0,
    is_archived     INTEGER DEFAULT 0,
    source_url      TEXT,
    source_app      TEXT,
    word_count      INTEGER,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 笔记历史版本
CREATE TABLE IF NOT EXISTS note_revisions (
    id          TEXT    PRIMARY KEY,
    note_id     TEXT    NOT NULL REFERENCES notes(id),
    content     TEXT    NOT NULL,
    version     INTEGER NOT NULL,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 书籍
CREATE TABLE IF NOT EXISTS books (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    author          TEXT,
    isbn            TEXT,
    publisher       TEXT,
    publish_year    INTEGER,
    pages           INTEGER,
    language        TEXT,
    cover_url       TEXT,
    description     TEXT,
    status          TEXT    NOT NULL DEFAULT 'wish',  -- wish/reading/done/abandoned
    current_page    INTEGER,
    started_at      TEXT,
    finished_at     TEXT,
    rating          REAL    CHECK(rating >= 0 AND rating <= 10),
    review          TEXT,
    location        TEXT,                   -- 实体书存放位置
    is_ebook        INTEGER DEFAULT 0,
    file_path       TEXT,
    source          TEXT,                   -- 购买/借阅/赠送
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 阅读笔记/高亮
CREATE TABLE IF NOT EXISTS book_highlights (
    id          TEXT    PRIMARY KEY,
    book_id     TEXT    NOT NULL REFERENCES books(id),
    chapter     TEXT,
    page        INTEGER,
    location    TEXT,
    text        TEXT    NOT NULL,
    note        TEXT,
    color       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 文章/网页保存
CREATE TABLE IF NOT EXISTS articles (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    url             TEXT,
    author          TEXT,
    source          TEXT,                   -- 来源网站/出版物
    content         TEXT,                   -- 正文
    summary         TEXT,
    word_count      INTEGER,
    read_time       INTEGER,                -- 预计阅读分钟数
    status          TEXT    DEFAULT 'unread', -- unread/reading/read/archived
    read_at         TEXT,
    is_favorite     INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 书签/收藏链接
CREATE TABLE IF NOT EXISTS bookmarks (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    url             TEXT    NOT NULL,
    description     TEXT,
    favicon_url     TEXT,
    folder          TEXT,                   -- 文件夹
    is_favorite     INTEGER DEFAULT 0,
    visit_count     INTEGER DEFAULT 0,
    last_visit_at   TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 名言/语录
CREATE TABLE IF NOT EXISTS quotes (
    id          TEXT    PRIMARY KEY,
    text        TEXT    NOT NULL,
    author      TEXT,
    source      TEXT,                       -- 出处（书名/文章名）
    source_id   TEXT,                       -- 关联的书籍/文章 ID
    source_type TEXT,                       -- books/articles
    is_favorite INTEGER DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 闪卡（记忆/学习用）
CREATE TABLE IF NOT EXISTS flashcards (
    id              TEXT    PRIMARY KEY,
    front           TEXT    NOT NULL,
    back            TEXT    NOT NULL,
    deck            TEXT,                   -- 牌组名
    hint            TEXT,
    difficulty      INTEGER DEFAULT 1,      -- 1-5
    interval        INTEGER DEFAULT 0,      -- 复习间隔(天)
    ease_factor     REAL    DEFAULT 2.5,     -- SM-2 算法参数
    next_review_at  TEXT,
    review_count    INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 闪卡复习记录
CREATE TABLE IF NOT EXISTS flashcard_reviews (
    id              TEXT    PRIMARY KEY,
    card_id         TEXT    NOT NULL REFERENCES flashcards(id),
    quality         INTEGER NOT NULL CHECK(quality >= 0 AND quality <= 5),
    reviewed_at     TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 学习课程/课程记录
CREATE TABLE IF NOT EXISTS courses (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    provider        TEXT,                   -- 学校/平台
    instructor      TEXT,
    platform        TEXT,                   -- Coursera/Udemy/edX/...
    url             TEXT,
    status          TEXT    DEFAULT 'planned', -- planned/in_progress/completed/dropped
    started_at      TEXT,
    completed_at    TEXT,
    certificate_url TEXT,
    rating          REAL    CHECK(rating >= 0 AND rating <= 10),
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 技能
CREATE TABLE IF NOT EXISTS skills (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    category        TEXT,                   -- programming/language/art/...
    proficiency     INTEGER CHECK(proficiency >= 1 AND proficiency <= 10),
    started_at      TEXT,
    hours_practiced REAL,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
