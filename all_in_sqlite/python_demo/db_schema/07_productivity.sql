-- ============================================================
-- 07_productivity.sql - 任务 / 项目 / 习惯 / 目标
-- ============================================================

-- 项目
CREATE TABLE IF NOT EXISTS projects (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    description     TEXT,
    status          TEXT    DEFAULT 'planning', -- planning/in_progress/on_hold/completed/cancelled
    priority        INTEGER DEFAULT 1,       -- 1-5
    start_date      TEXT,
    due_date        TEXT,
    completed_at    TEXT,
    color           TEXT,
    contact_id      TEXT    REFERENCES contacts(id),  -- 相关人
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 任务
CREATE TABLE IF NOT EXISTS tasks (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    description     TEXT,
    status          TEXT    DEFAULT 'todo',  -- todo/in_progress/done/cancelled
    priority        INTEGER DEFAULT 1,       -- 1-5
    due_date        TEXT,
    completed_at    TEXT,
    project_id      TEXT    REFERENCES projects(id),
    parent_id       TEXT    REFERENCES tasks(id),  -- 子任务
    sort_order      INTEGER DEFAULT 0,
    estimated_minutes INTEGER,
    actual_minutes  INTEGER,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 习惯追踪
CREATE TABLE IF NOT EXISTS habits (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    description     TEXT,
    frequency       TEXT    NOT NULL,        -- daily/weekly/monthly/custom
    frequency_times INTEGER DEFAULT 1,      -- 每周几次等
    target_value    REAL,                    -- 每天走10000步
    unit            TEXT,                    -- 步/分钟/页
    icon            TEXT,
    color           TEXT,
    is_negative     INTEGER DEFAULT 0,       -- 戒除坏习惯
    is_active       INTEGER DEFAULT 1,
    started_at      TEXT    NOT NULL,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 习惯打卡记录
CREATE TABLE IF NOT EXISTS habit_logs (
    id          TEXT    PRIMARY KEY,
    habit_id    TEXT    NOT NULL REFERENCES habits(id),
    log_date    TEXT    NOT NULL,
    value       REAL,                        -- 若习惯可量化
    note        TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(habit_id, log_date)
);

-- 目标（OKR 风格）
CREATE TABLE IF NOT EXISTS goals (
    id              TEXT    PRIMARY KEY,
    title           TEXT    NOT NULL,
    description     TEXT,
    category        TEXT,                    -- health/career/finance/learning/...
    type            TEXT    DEFAULT 'yearly', -- yearly/quarterly/monthly/lifetime
    status          TEXT    DEFAULT 'active', -- active/completed/abandoned
    start_date      TEXT    NOT NULL,
    target_date     TEXT,
    completed_at    TEXT,
    progress        REAL    DEFAULT 0,       -- 0-100%
    measurement     TEXT,                    -- 衡量标准
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 关键结果（Key Results）
CREATE TABLE IF NOT EXISTS key_results (
    id          TEXT    PRIMARY KEY,
    goal_id     TEXT    NOT NULL REFERENCES goals(id),
    title       TEXT    NOT NULL,
    start_value REAL    DEFAULT 0,
    target_value REAL   NOT NULL,
    current_value REAL  DEFAULT 0,
    unit        TEXT,
    status      TEXT    DEFAULT 'on_track', -- on_track/at_risk/behind/done
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 里程碑
CREATE TABLE IF NOT EXISTS milestones (
    id          TEXT    PRIMARY KEY,
    target_id   TEXT    NOT NULL,
    target_type TEXT    NOT NULL,            -- projects/tasks/goals
    title       TEXT    NOT NULL,
    date        TEXT    NOT NULL,
    is_reached  INTEGER DEFAULT 0,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 番茄钟/专注记录
CREATE TABLE IF NOT EXISTS focus_sessions (
    id              TEXT    PRIMARY KEY,
    task_id         TEXT    REFERENCES tasks(id),
    start_time      TEXT    NOT NULL,
    end_time        TEXT,
    duration         INTEGER,                -- 分钟
    interruptions   INTEGER DEFAULT 0,
    energy_level    INTEGER,                -- 1-5
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 时间日志（手动记录时间花销）
CREATE TABLE IF NOT EXISTS time_logs (
    id          TEXT    PRIMARY KEY,
    start_time  TEXT    NOT NULL,
    end_time    TEXT,
    duration     INTEGER,                   -- 分钟
    category    TEXT,                       -- work/study/leisure/...
    description TEXT,
    task_id     TEXT    REFERENCES tasks(id),
    project_id  TEXT    REFERENCES projects(id),
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
