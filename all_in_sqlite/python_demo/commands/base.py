"""
base.py - 通用 CRUD 命令处理器
通过配置自动生成 add/list/show/edit/delete/search 等命令
"""

from .. import db
from .. import render


class Field:
    def __init__(self, name: str, label: str = None, ftype: str = "text",
                 required: bool = False, default=None, options: list = None,
                 skip_in_list: bool = False, skip_in_detail: bool = False):
        self.name = name
        self.label = label or name.replace("_", " ").title()
        self.ftype = ftype          # text, int, float, date, textarea, select
        self.required = required
        self.default = default
        self.options = options       # for select type
        self.skip_in_list = skip_in_list
        self.skip_in_detail = skip_in_detail


class EntityConfig:
    def __init__(self, domain: str, table: str, label: str, label_plural: str,
                 fields: list[Field], list_fields: list[str] = None,
                 search_fields: list[str] = None, order: str = "created_at DESC",
                 soft_delete: bool = True, list_limit: int = 30):
        self.domain = domain
        self.table = table
        self.label = label
        self.label_plural = label_plural or f"{label}s"
        self.fields = fields
        self.list_fields = list_fields or [f.name for f in fields if not f.skip_in_list][:6]
        self.search_fields = search_fields or [f.name for f in fields if f.ftype == "text"]
        self.order = order
        self.soft_delete = soft_delete
        self.list_limit = list_limit

    def get_field(self, name: str) -> Field | None:
        for f in self.fields:
            if f.name == name:
                return f
        return None


def build_detail(config: EntityConfig, row: dict) -> dict:
    """去掉 skip_in_detail 的字段，排序"""
    result = {}
    for f in config.fields:
        if not f.skip_in_detail and f.name in row:
            result[f.label] = row[f.name]
    result["ID"] = row.get("id", "")
    result["Created"] = row.get("created_at", "")
    result["Updated"] = row.get("updated_at", "")
    return result


def do_add(config: EntityConfig):
    data = {}
    for f in config.fields:
        if f.name in ("id", "created_at", "updated_at", "deleted_at"):
            continue
        opts = {"default": f.default, "required": f.required}
        val = render.prompt_input(f.label, **opts)
        if f.ftype == "int":
            val = int(val) if val else None
        elif f.ftype == "float":
            val = float(val) if val else None
        elif f.ftype == "select" and f.options and val not in f.options:
            print(f"  invalid option. choose from: {', '.join(f.options)}")
            return do_add(config)
        data[f.name] = val if val else None

    # auto-fill account_id from default cash account if empty
    if "account_id" in data and not data.get("account_id"):
        cash = db.query_one("SELECT id FROM financial_accounts WHERE name='现金'")
        if cash:
            data["account_id"] = cash["id"]

    # handle tags from interactive prompt
    tag_str = render.prompt_input("Tags (comma separated)")
    rid = db.insert(config.table, data)
    print(f"  [OK] added {config.label}: {rid[:8]}...")

    if tag_str:
        _attach_tags(rid, config.table, tag_str)
    return rid


def _attach_tags(target_id: str, target_type: str, tag_str: str):
    for t in tag_str.split(","):
        t = t.strip()
        if not t:
            continue
        existing = db.query_one("SELECT id FROM tags WHERE name=?", (t,))
        if existing:
            tid = existing["id"]
        else:
            tid = db.insert("tags", {"name": t})
        try:
            db.insert("taggings", {"tag_id": tid, "target_id": target_id, "target_type": target_type})
        except Exception:
            pass


def do_list(config: EntityConfig, args: list[str] = None):
    page = 0
    where = "1=1"
    params = []
    if args:
        for a in args:
            if a.startswith("--page="):
                page = int(a.split("=", 1)[1])
    offset = page * config.list_limit
    rows = db.list_all(config.table, where=where, order=config.order,
                       limit=config.list_limit, offset=offset, params=tuple(params))
    dicts = [{k: row[k] for k in config.list_fields if k in row.keys()} for row in rows]
    render.print_table(dicts)


def do_search(config: EntityConfig, keyword: str):
    if not keyword:
        print("  usage: <domain> search <keyword>")
        return
    clauses = [f"{f} LIKE ?" for f in config.search_fields]
    where = f"({' OR '.join(clauses)})"
    params = tuple(f"%{keyword}%" for _ in config.search_fields)
    rows = db.list_all(config.table, where=where, params=params, limit=30)
    dicts = [{k: row[k] for k in config.list_fields if k in row.keys()} for row in rows]
    render.print_table(dicts)


def do_show(config: EntityConfig, id_val: str):
    row = db.query_one(f"SELECT * FROM {config.table} WHERE id=?", (id_val,))
    if not row:
        row = db.query_one(f"SELECT * FROM {config.table} WHERE id LIKE ?", (id_val + "%",))
    if not row:
        print(f"  [ERROR] {config.label} not found: {id_val}")
        return
    detail = build_detail(config, dict(row))
    render.print_table([detail])


def do_edit(config: EntityConfig, id_val: str):
    row = db.query_one(f"SELECT * FROM {config.table} WHERE id=?", (id_val,))
    if not row:
        print(f"  [ERROR] {config.label} not found: {id_val}")
        return
    data = {}
    for f in config.fields:
        if f.name in ("id", "created_at", "updated_at", "deleted_at"):
            continue
        current = row[f.name]
        val = render.prompt_input(f.label, default=str(current) if current is not None else "")
        if f.ftype == "int":
            val = int(val) if val else None
        elif f.ftype == "float":
            val = float(val) if val else None
        data[f.name] = val if val else None
    db.update(config.table, id_val, data)
    print(f"  [OK] updated {config.label}: {id_val[:8]}...")


def do_delete(config: EntityConfig, id_val: str):
    row = db.query_one(f"SELECT id FROM {config.table} WHERE id=?", (id_val,))
    if not row:
        print(f"  [ERROR] {config.label} not found: {id_val}")
        return
    if render.prompt_confirm(f"Delete this {config.label}?"):
        db.delete(config.table, id_val, soft=config.soft_delete)
        print(f"  [OK] deleted {config.label}: {id_val[:8]}...")


def do_count(config: EntityConfig):
    total = db.count(config.table)
    print(f"  total {config.label_plural}: {total}")
