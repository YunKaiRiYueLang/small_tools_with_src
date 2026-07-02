-- ============================================================
-- 12_communication.sql - 通讯记录 / 消息 / 邮件 / 通话
-- ============================================================

-- 电子邮件记录（只存元数据，全文可存外部）
CREATE TABLE IF NOT EXISTS emails (
    id              TEXT    PRIMARY KEY,
    message_id      TEXT,                   -- RFC 822 Message-ID
    thread_id       TEXT,
    from_name       TEXT,
    from_address    TEXT    NOT NULL,
    to_recipients   TEXT    NOT NULL,       -- JSON array
    cc_recipients   TEXT,                   -- JSON array
    bcc_recipients  TEXT,                   -- JSON array
    subject         TEXT    NOT NULL,
    snippet         TEXT,                   -- 纯文本摘要
    body_path       TEXT,                   -- 外部存储路径（含附件）
    is_read         INTEGER DEFAULT 0,
    is_starred      INTEGER DEFAULT 0,
    is_attachment    INTEGER DEFAULT 0,
    sent_at         TEXT    NOT NULL,
    received_at     TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 即时消息（微信/Telegram/SMS 等）
CREATE TABLE IF NOT EXISTS messages (
    id              TEXT    PRIMARY KEY,
    conversation_id TEXT    NOT NULL,
    platform        TEXT    NOT NULL,       -- wechat/telegram/whatsapp/sms/...
    sender_id       TEXT,                   -- 发送者 ID
    sender_name     TEXT,
    content         TEXT,
    content_type    TEXT    DEFAULT 'text',  -- text/image/file/location/...
    file_path       TEXT,                   -- 附件路径
    sent_at         TEXT    NOT NULL,
    is_from_me      INTEGER DEFAULT 0,
    is_read         INTEGER DEFAULT 1,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 会话摘要
CREATE TABLE IF NOT EXISTS conversations (
    id              TEXT    PRIMARY KEY,
    platform        TEXT    NOT NULL,
    name            TEXT,
    contact_ids     TEXT,                    -- JSON array
    last_message_at TEXT,
    message_count   INTEGER DEFAULT 0,
    is_archived     INTEGER DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 通话记录
CREATE TABLE IF NOT EXISTS phone_calls (
    id              TEXT    PRIMARY KEY,
    contact_id      TEXT    REFERENCES contacts(id),
    phone_number    TEXT,
    direction       TEXT    NOT NULL,       -- incoming/outgoing/missed
    duration        INTEGER,                -- 秒
    datetime        TEXT    NOT NULL,
    call_type       TEXT,                   -- voice/video
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 礼物记录（收/送）
CREATE TABLE IF NOT EXISTS gifts (
    id          TEXT    PRIMARY KEY,
    contact_id  TEXT    NOT NULL REFERENCES contacts(id),
    direction   TEXT    NOT NULL,           -- sent/received
    name        TEXT    NOT NULL,
    price       REAL,
    occasion    TEXT,                       -- birthday/wedding/Christmas/...
    date        TEXT    NOT NULL,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
