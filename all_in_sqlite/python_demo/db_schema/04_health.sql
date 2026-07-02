-- ============================================================
-- 04_health.sql - 健康 / 医疗 / 健身
-- ============================================================

-- 体检/医疗记录
CREATE TABLE IF NOT EXISTS medical_records (
    id              TEXT    PRIMARY KEY,
    date            TEXT    NOT NULL,
    type            TEXT    NOT NULL,       -- checkup/diagnosis/surgery/vaccination/...
    hospital        TEXT,
    doctor          TEXT,
    diagnosis       TEXT,
    prescription    TEXT,
    notes           TEXT,
    cost            REAL,
    follow_up_date  TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 用药记录
CREATE TABLE IF NOT EXISTS medications (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    dosage          TEXT,                   -- "500mg"
    frequency       TEXT,                   -- "1日3次"
    started_at      TEXT,
    ended_at        TEXT,
    notes           TEXT,
    record_id       TEXT    REFERENCES medical_records(id),
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 身体指标（可穿戴设备数据）
CREATE TABLE IF NOT EXISTS vitals (
    id              TEXT    PRIMARY KEY,
    logged_at       TEXT    NOT NULL,       -- 精确到分钟
    weight          REAL,                   -- kg
    height          REAL,                   -- cm
    bmi             REAL,
    systolic_bp     INTEGER,                -- 收缩压 mmHg
    diastolic_bp    INTEGER,                -- 舒张压 mmHg
    heart_rate      INTEGER,                -- bpm
    blood_oxygen    REAL,                   -- SpO2 %
    blood_sugar     REAL,                   -- mmol/L
    body_fat        REAL,                   -- 体脂率 %
    temperature     REAL,                   -- 体温 ℃
    respiration     INTEGER,                -- 呼吸频率
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 运动记录
CREATE TABLE IF NOT EXISTS exercise_log (
    id              TEXT    PRIMARY KEY,
    date            TEXT    NOT NULL,
    type            TEXT    NOT NULL,       -- running/swimming/cycling/yoga/...
    duration        INTEGER,                -- 分钟
    distance        REAL,                   -- km
    calories        INTEGER,                -- kcal
    heart_rate_avg  INTEGER,
    heart_rate_max  INTEGER,
    steps           INTEGER,
    route_data      TEXT,                   -- JSON: GPS track
    intensity       TEXT,                   -- low/medium/high
    notes           TEXT,
    location_id     TEXT    REFERENCES locations(id),
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 睡眠记录
CREATE TABLE IF NOT EXISTS sleep_log (
    id              TEXT    PRIMARY KEY,
    date            TEXT    NOT NULL,       -- 入睡日期
    bed_time        TEXT    NOT NULL,       -- 入睡时间
    wake_time       TEXT    NOT NULL,       -- 醒来时间
    duration        INTEGER NOT NULL,       -- 总睡眠（分钟）
    deep_sleep      INTEGER,                -- 深睡（分钟）
    light_sleep     INTEGER,                -- 浅睡（分钟）
    rem_sleep       INTEGER,                -- REM（分钟）
    awakenings      INTEGER,                -- 醒来次数
    quality         INTEGER,                -- 质量评分 1-10
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 饮食/饮食日志
CREATE TABLE IF NOT EXISTS food_log (
    id              TEXT    PRIMARY KEY,
    datetime        TEXT    NOT NULL,
    meal_type       TEXT,                   -- breakfast/lunch/dinner/snack
    food_name       TEXT    NOT NULL,
    portion         TEXT,                   -- "1碗"/"200g"
    calories        INTEGER,
    protein         REAL,                   -- g
    carbs           REAL,                   -- g
    fat             REAL,                   -- g
    fiber           REAL,                   -- g
    sodium          REAL,                   -- mg
    sugar           REAL,                   -- g
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 过敏/不适记录
CREATE TABLE IF NOT EXISTS symptom_log (
    id              TEXT    PRIMARY KEY,
    datetime        TEXT    NOT NULL,
    symptom         TEXT    NOT NULL,       -- headache/fever/rash/...
    severity        INTEGER CHECK(severity >= 1 AND severity <= 10),
    duration        TEXT,                   -- "2小时"
    possible_cause  TEXT,
    relief_method   TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 疫苗接种
CREATE TABLE IF NOT EXISTS vaccinations (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    dose_number     INTEGER,
    date            TEXT    NOT NULL,
    location        TEXT,
    batch_number    TEXT,
    notes           TEXT,
    next_due_date   TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
