"""
repl.py - 交互式 REPL 主循环
"""

import shlex
from . import db, render
from .commands.base import (
    do_add, do_list, do_show, do_edit, do_delete, do_search, do_count
)
from .commands.configs import get as get_config, all_configs


def print_welcome():
    render.print_header("Life Data Manager v0.1")
    print("  Type 'help' for commands, 'exit' to quit.")
    print()

def print_help():
    lines = [
        ("help", "Show this help"),
        ("exit / quit", "Exit the console"),
        (".tables", "List all entity types"),
        (".stats", "Show database statistics"),
        ("<domain> add", "Add a new record"),
        ("<domain> list", "List records (--page=N for pagination)"),
        ("<domain> show <id>", "Show record details"),
        ("<domain> edit <id>", "Edit a record"),
        ("<domain> delete <id>", "Delete a record"),
        ("<domain> search <text>", "Search across records"),
        ("<domain> count", "Count total records"),
        ("now <activity>", "Start tracking: now 写代码"),
        ("done", "Stop current activity and log duration"),
        ("spend <amt> <desc> [cat]", "Quick expense: spend 25 午餐 food"),
        ("earn <amt> <desc> [cat]", "Quick income: earn 5000 工资 salary"),
    ]
    render.print_help(lines)
    print("  Domains:", ", ".join(sorted(all_configs().keys())))
    print()

def cmd_tables():
    cfgs = all_configs()
    render.print_table([
        {"domain": k, "table": v.table, "records": v.label_plural}
        for k, v in sorted(cfgs.items())
    ])

def cmd_stats():
    cfgs = all_configs()
    data = []
    for k, v in sorted(cfgs.items()):
        try:
            cnt = db.count(v.table)
        except Exception:
            cnt = "?"
        data.append({"domain": k, "table": v.table, "count": cnt})
    render.print_table(data)

def cmd_domain_action(domain: str, action: str, args: list[str]):
    cfg = get_config(domain)
    if not cfg:
        print(f"  [ERROR] unknown domain: {domain}")
        print(f"  available: {', '.join(sorted(all_configs().keys()))}")
        return

    if action == "add":
        do_add(cfg)
    elif action == "list":
        do_list(cfg, args)
    elif action == "show":
        if not args:
            print("  usage: <domain> show <id>")
            return
        do_show(cfg, args[0])
    elif action == "edit":
        if not args:
            print("  usage: <domain> edit <id>")
            return
        do_edit(cfg, args[0])
    elif action == "delete":
        if not args:
            print("  usage: <domain> delete <id>")
            return
        do_delete(cfg, args[0])
    elif action == "search":
        keyword = " ".join(args) if args else ""
        do_search(cfg, keyword)
    elif action == "count":
        do_count(cfg)
    else:
        print(f"  [ERROR] unknown action: {action}")
        print(f"  actions: add, list, show, edit, delete, search, count")

def run(db_path: str):
    db.init(db_path)
    print_welcome()

    while True:
        try:
            line = input("life> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if not line:
            continue

        # handle dot commands
        if line.startswith("."):
            parts = shlex.split(line)
            cmd = parts[0].lower()
            if cmd == ".tables":
                cmd_tables()
            elif cmd == ".stats":
                cmd_stats()
            else:
                print(f"  [ERROR] unknown dot command: {cmd}")
            continue

        parts = shlex.split(line)
        cmd = parts[0].lower()

        if cmd in ("exit", "quit"):
            break
        elif cmd == "help":
            print_help()
        elif cmd == "now":
            # 快速记录正在做的事: now <activity>
            if len(parts) < 2:
                print("  usage: now <what are you doing>")
                print("  example: now 写代码")
            else:
                activity = " ".join(parts[1:])
                now_ts = db.now()
                db.insert("time_logs", {
                    "start_time": now_ts,
                    "description": activity,
                })
                print(f"  [OK] started at {now_ts}: {activity}")
        elif cmd == "done":
            # 结束最近一条未结束的时间记录
            row = db.query_one(
                "SELECT id, start_time, description FROM time_logs WHERE end_time IS NULL ORDER BY start_time DESC LIMIT 1"
            )
            if not row:
                print("  no active time log found. start one with: now <activity>")
            else:
                end_ts = db.now()
                from datetime import datetime
                fmt = "%Y-%m-%dT%H:%M:%S"
                try:
                    s = datetime.strptime(row["start_time"][:19], fmt)
                    e = datetime.strptime(end_ts[:19], fmt)
                    dur = int((e - s).total_seconds() / 60)
                except Exception:
                    dur = 0
                db.update("time_logs", row["id"], {"end_time": end_ts, "duration": dur})
                print(f"  [OK] ended: {row['description']} ({dur} min)")
        elif cmd == "spend":
            # 快捷消费记录: spend <金额> <说明> [分类]
            if len(parts) < 3:
                print("  usage: spend <amount> <description> [category]")
                print("  example: spend 25 午餐 food")
                print("  example: spend 3.5 地铁 transport")
            else:
                try:
                    amount = float(parts[1])
                except ValueError:
                    print(f"  [ERROR] invalid amount: {parts[1]}")
                    return
                description = parts[2]
                category = parts[3] if len(parts) > 3 else "other"
                now_ts = db.now()
                cash = db.query_one("SELECT id FROM financial_accounts WHERE name='现金'")
                acct_id = cash["id"] if cash else None
                db.insert("transactions", {
                    "account_id": acct_id,
                    "type": "expense",
                    "amount": amount,
                    "category": category,
                    "description": description,
                    "datetime": now_ts,
                })
                print(f"  [OK] spent {amount} on {description} ({category})")
        elif cmd == "earn":
            if len(parts) < 3:
                print("  usage: earn <amount> <description> [category]")
            else:
                try:
                    amount = float(parts[1])
                except ValueError:
                    print(f"  [ERROR] invalid amount: {parts[1]}")
                    return
                description = parts[2]
                category = parts[3] if len(parts) > 3 else "salary"
                now_ts = db.now()
                cash = db.query_one("SELECT id FROM financial_accounts WHERE name='现金'")
                acct_id = cash["id"] if cash else None
                db.insert("transactions", {
                    "account_id": acct_id,
                    "type": "income",
                    "amount": amount,
                    "category": category,
                    "description": description,
                    "datetime": now_ts,
                })
                print(f"  [OK] earned {amount} from {description} ({category})")
        elif cmd in all_configs():
            # domain command: domain action [args...]
            if len(parts) < 2:
                print(f"  usage: {cmd} <action> [args]")
                print(f"  actions: add, list, show, edit, delete, search, count")
            else:
                cmd_domain_action(cmd, parts[1].lower(), parts[2:])
        else:
            print(f"  [ERROR] unknown command: {cmd}")
            print(f"  Type 'help' for available commands.")

    db.close()
    print("bye.")
