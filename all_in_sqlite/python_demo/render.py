"""
render.py - 控制台格式化输出
"""

def print_header(text: str):
    width = 60
    print()
    print("=" * width)
    print(f"  {text}")
    print("=" * width)

def print_info(label: str, value, indent: int = 0):
    pad = "  " * indent
    if value is None:
        value = ""
    print(f"{pad}{label}: {value}")

def print_dict(data: dict, title: str = None, skip_keys: set = None):
    if title:
        print_header(title)
    if skip_keys is None:
        skip_keys = {"id", "created_at", "updated_at", "deleted_at"}
    for k, v in data.items():
        if k not in skip_keys and v is not None:
            print_info(k.replace("_", " ").title(), v)

def print_table(rows: list[dict], max_col_width: int = 50):
    if not rows:
        print("  (no results)")
        return

    cols = list(rows[0].keys())
    col_widths = {c: len(str(c)) for c in cols}
    for row in rows:
        for c in cols:
            val = str(row.get(c, ""))
            col_widths[c] = max(col_widths[c], min(len(val), max_col_width))

    total_w = sum(col_widths.values()) + 3 * len(cols) + 1
    sep = "+" + "+".join("-" * (col_widths[c] + 2) for c in cols) + "+"

    def fmt_row(vals: dict) -> str:
        line = "|"
        for c in cols:
            val = str(vals.get(c, ""))
            if len(val) > max_col_width:
                val = val[:max_col_width - 3] + "..."
            line += f" {val:<{col_widths[c]}} |"
        return line

    print(sep)
    print(fmt_row({c: str(c) for c in cols}))
    print(sep)
    for row in rows:
        print(fmt_row(row))
    print(sep)
    print(f"  total: {len(rows)} rows")

def print_help(commands: list[tuple[str, str]]):
    print_header("Commands")
    for cmd, desc in commands:
        print(f"  {cmd:<35} {desc}")
    print()

def prompt_input(label: str, default: str = "", required: bool = False) -> str:
    if default:
        label = f"{label} [{default}]"
    val = input(f"  {label}: ").strip()
    if not val and default:
        return default
    if not val and required:
        return prompt_input(label, default, required)
    return val

def prompt_confirm(msg: str) -> bool:
    r = input(f"  {msg} (y/N): ").strip().lower()
    return r == "y"
