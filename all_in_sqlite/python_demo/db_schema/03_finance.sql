-- ============================================================
-- 03_finance.sql - 财务 / 资产管理
-- ============================================================

-- 账户（银行卡、现金、支付宝、微信、投资账户等）
CREATE TABLE IF NOT EXISTS financial_accounts (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    type            TEXT    NOT NULL,       -- cash/bank/credit_card/investment/e_wallet/...
    currency        TEXT    NOT NULL DEFAULT 'CNY',
    balance         REAL    NOT NULL DEFAULT 0,
    institution     TEXT,                   -- 银行名称
    account_number  TEXT,                   -- 脱敏账号（尾号）
    color           TEXT,
    icon            TEXT,
    is_active       INTEGER DEFAULT 1,
    sort_order      INTEGER DEFAULT 0,
    opened_at       TEXT,
    closed_at       TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    deleted_at      TEXT
);

-- 交易记录
CREATE TABLE IF NOT EXISTS transactions (
    id              TEXT    PRIMARY KEY,
    account_id      TEXT    NOT NULL REFERENCES financial_accounts(id),
    type            TEXT    NOT NULL,       -- income/expense/transfer
    amount          REAL    NOT NULL,
    currency        TEXT    NOT NULL DEFAULT 'CNY',
    category        TEXT,                   -- food/transport/shopping/...
    subcategory     TEXT,
    datetime        TEXT    NOT NULL,
    description     TEXT,
    merchant        TEXT,
    location_id     TEXT    REFERENCES locations(id),
    transaction_id  TEXT,                   -- 外部流水号
    is_recurring    INTEGER DEFAULT 0,
    tags            TEXT,                   -- JSON array
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 预算
CREATE TABLE IF NOT EXISTS budgets (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    category        TEXT,                   -- 对应 transactions.category
    period          TEXT    NOT NULL,       -- monthly/yearly/weekly
    amount          REAL    NOT NULL,
    start_date      TEXT    NOT NULL,
    end_date        TEXT,
    notes           TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 投资持仓
CREATE TABLE IF NOT EXISTS investments (
    id              TEXT    PRIMARY KEY,
    account_id      TEXT    NOT NULL REFERENCES financial_accounts(id),
    symbol          TEXT    NOT NULL,       -- 股票代码/基金代码
    name            TEXT    NOT NULL,
    type            TEXT    NOT NULL,       -- stock/fund/bond/crypto/commodity/...
    quantity         REAL    NOT NULL,
    cost_price      REAL    NOT NULL,       -- 成本价
    current_price   REAL,                   -- 当前价（冗余，可刷新）
    currency        TEXT    NOT NULL DEFAULT 'CNY',
    broker          TEXT,
    notes           TEXT,
    bought_at       TEXT,
    sold_at         TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 账单/周期性支出
CREATE TABLE IF NOT EXISTS bills (
    id              TEXT    PRIMARY KEY,
    name            TEXT    NOT NULL,
    amount          REAL    NOT NULL,
    currency        TEXT    NOT NULL DEFAULT 'CNY',
    category        TEXT,
    due_day         INTEGER,               -- 每月几号
    due_date        TEXT,                   -- 或固定到期日
    auto_pay        INTEGER DEFAULT 0,
    payee           TEXT,
    notes           TEXT,
    is_active       INTEGER DEFAULT 1,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- 债务/借贷
CREATE TABLE IF NOT EXISTS debts (
    id              TEXT    PRIMARY KEY,
    contact_id      TEXT    REFERENCES contacts(id),
    type            TEXT    NOT NULL,       -- lend/borrow
    amount          REAL    NOT NULL,
    currency        TEXT    NOT NULL DEFAULT 'CNY',
    remaining       REAL    NOT NULL,
    interest_rate   REAL,
    description     TEXT,
    borrowed_at     TEXT    NOT NULL,
    due_at          TEXT,
    settled_at      TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
