"""
init_db.py - 数据库初始化脚本
读取所有 .sql 文件并按顺序执行，创建完整数据库结构
"""

import sqlite3
import uuid
import json
from datetime import datetime
from pathlib import Path


def generate_id() -> str:
    return str(uuid.uuid4())


def now() -> str:
    return datetime.now().isoformat()


def init_database(db_path: str, schema_dir: str = None) -> sqlite3.Connection:
    if schema_dir is None:
        schema_dir = Path(__file__).parent

    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    conn.execute("PRAGMA busy_timeout=5000")

    sql_dir = Path(schema_dir)
    sql_files = sorted(sql_dir.glob("[0-9]*.sql"))

    for sql_file in sql_files:
        print(f"  applying: {sql_file.name}")
        sql = sql_file.read_text(encoding="utf-8")
        conn.executescript(sql)

    conn.commit()
    print(f"\n  database initialized: {db_path}")
    return conn


if __name__ == "__main__":
    import sys

    db_path = sys.argv[1] if len(sys.argv) > 1 else "life_data.db"
    init_database(db_path)
    print("done")
