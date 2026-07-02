import sqlite3
import uuid
from datetime import datetime
from pathlib import Path

_DB = None
_SCHEMA_CACHE: dict[str, set[str]] = {}

def generate_id() -> str:
    return str(uuid.uuid4())

def now() -> str:
    return datetime.now().isoformat()

def get_db() -> sqlite3.Connection:
    global _DB
    if _DB is None:
        raise RuntimeError("Database not initialized. Call init() first.")
    return _DB

def _columns(table: str) -> set[str]:
    if table not in _SCHEMA_CACHE:
        rows = get_db().execute(f"PRAGMA table_info({table})").fetchall()
        _SCHEMA_CACHE[table] = {r[1] for r in rows}
    return _SCHEMA_CACHE[table]

def init(db_path: str = "life_data.db") -> sqlite3.Connection:
    global _DB
    _DB = sqlite3.connect(db_path)
    _DB.execute("PRAGMA journal_mode=WAL")
    _DB.execute("PRAGMA foreign_keys=ON")
    _DB.execute("PRAGMA busy_timeout=5000")
    _DB.row_factory = sqlite3.Row
    _apply_schema(_DB)
    _ensure_defaults(_DB)
    return _DB

def _ensure_defaults(conn: sqlite3.Connection):
    has = conn.execute("SELECT COUNT(*) FROM financial_accounts").fetchone()[0]
    if has == 0:
        conn.execute(
            "INSERT INTO financial_accounts (id, name, type, currency, balance) VALUES (?, ?, ?, ?, ?)",
            (generate_id(), "现金", "cash", "CNY", 0)
        )
        conn.commit()

def _apply_schema(conn: sqlite3.Connection):
    schema_dir = Path(__file__).parent / "db_schema"
    sql_files = sorted(schema_dir.glob("[0-9]*.sql"))
    for f in sql_files:
        conn.executescript(f.read_text(encoding="utf-8"))
    conn.commit()

def close():
    global _DB
    if _DB:
        _DB.close()
        _DB = None

def query(sql: str, params: tuple = ()) -> list[sqlite3.Row]:
    return get_db().execute(sql, params).fetchall()

def query_one(sql: str, params: tuple = ()) -> sqlite3.Row | None:
    return get_db().execute(sql, params).fetchone()

def execute(sql: str, params: tuple = ()) -> int:
    cur = get_db().execute(sql, params)
    get_db().commit()
    return cur.rowcount

def insert(table: str, data: dict) -> str:
    cols_set = _columns(table)
    data = {k: v for k, v in data.items() if k in cols_set}
    if "id" not in data and "id" in cols_set:
        data["id"] = generate_id()
    now_ts = now()
    if "created_at" in cols_set and "created_at" not in data:
        data["created_at"] = now_ts
    if "updated_at" in cols_set and "updated_at" not in data:
        data["updated_at"] = now_ts
    cols = ", ".join(data.keys())
    placeholders = ", ".join("?" for _ in data)
    sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"
    get_db().execute(sql, tuple(data.values()))
    get_db().commit()
    return data["id"]

def update(table: str, id_val: str, data: dict) -> bool:
    cols_set = _columns(table)
    data = {k: v for k, v in data.items() if k in cols_set}
    if "updated_at" in cols_set:
        data["updated_at"] = now()
    if not data:
        return False
    sets = ", ".join(f"{k}=?" for k in data)
    sql = f"UPDATE {table} SET {sets} WHERE id=?"
    cur = get_db().execute(sql, tuple(data.values()) + (id_val,))
    get_db().commit()
    return cur.rowcount > 0

def delete(table: str, id_val: str, soft: bool = True) -> bool:
    if soft and "deleted_at" in _columns(table):
        return update(table, id_val, {"deleted_at": now()})
    cur = get_db().execute(f"DELETE FROM {table} WHERE id=?", (id_val,))
    get_db().commit()
    return cur.rowcount > 0

def count(table: str, where: str = "1=1", params: tuple = ()) -> int:
    has_deleted = "deleted_at" in _columns(table)
    if has_deleted and "deleted_at" not in where:
        where = f"({where}) AND deleted_at IS NULL"
    row = query_one(f"SELECT COUNT(*) as cnt FROM {table} WHERE {where}", params)
    return row["cnt"] if row else 0

def list_all(table: str, fields: str = "*", where: str = "deleted_at IS NULL",
             order: str = "created_at DESC", limit: int = 50, offset: int = 0,
             params: tuple = ()) -> list[sqlite3.Row]:
    has_deleted = "deleted_at" in _columns(table)
    if has_deleted and "deleted_at" not in where:
        where = f"({where}) AND deleted_at IS NULL" if where != "deleted_at IS NULL" else where
    sql = f"SELECT {fields} FROM {table} WHERE {where} ORDER BY {order} LIMIT ? OFFSET ?"
    return query(sql, params + (limit, offset))
