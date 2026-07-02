#!/usr/bin/env python3
"""
Life Data Manager - 把一生的数据都存进 SQLite

Usage:
  python cli.py                        # interactive REPL
  python cli.py --db <path>            # use custom database path
"""

import sys, os, argparse

# 确保能找到包
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from python_demo import repl


def main():
    parser = argparse.ArgumentParser(description="Life Data Manager")
    parser.add_argument("--db", default="life_data.db", help="SQLite database path")
    args = parser.parse_args()

    repl.run(args.db)


if __name__ == "__main__":
    main()
