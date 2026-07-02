# Life Data Manager - 控制台版

把一生的数据都存进 SQLite，通过交互式控制台管理。

## 启动

```bash
# 方式一：直接运行
D:\ProgramData\anaconda3\python.exe cli.py

# 方式二：指定数据库路径（默认 life_data.db）
D:\ProgramData\anaconda3\python.exe cli.py --db my_life.db
```

启动后进入交互式 REPL，提示符为 `life>`。

## 基础命令

| 命令 | 说明 |
|------|------|
| `help` | 显示所有命令 |
| `exit` / `quit` | 退出 |
| `.tables` | 列出所有数据领域 |
| `.stats` | 各领域记录统计 |

## 快捷记录命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `now <活动>` | 开始记录当前活动 | `now 写代码` |
| `done` | 结束当前活动，自动算耗时 | `done` |
| `spend <金额> <说明> [分类]` | 记录一笔支出 | `spend 25 午餐 food` |
| `earn <金额> <说明> [分类]` | 记录一笔收入 | `earn 15000 工资 salary` |

## 数据领域通用操作

每个领域都支持以下 7 个操作：

### 领域列表

```
account, article, book, contact, diary, event, exercise,
food, goal, habit, life-event, mood, movie, note, place,
reminder, sleep, subscription, task, time-log, transaction,
trip, vital
```

### 操作格式

```
<领域> add          # 交互式添加（按提示填字段）
<领域> list         # 列出记录
<领域> show <id>    # 查看详情
<领域> edit <id>    # 编辑记录
<领域> delete <id>  # 删除记录
<领域> search <词>  # 搜索
<领域> count        # 统计总数
```

### 示例

```
life> contact add              # 添加联系人（交互填字段）
life> diary list               # 列出日记
life> diary search 周末         # 搜索日记
life> transaction list          # 查看所有消费
life> book add                  # 添加书籍
life> note add                  # 写笔记
life> task add                  # 添加任务
life> habit add                 # 添加习惯
life> time-log add              # 手动添加时间记录
```

## 数据领域说明

| 领域 | 对应表 | 用途 |
|------|--------|------|
| `contact` | contacts | 联系人/人脉 |
| `diary` | diary_entries | 日记 |
| `mood` | mood_log | 情绪追踪 |
| `transaction` | transactions | 收支流水 |
| `account` | financial_accounts | 银行/支付账户 |
| `vital` | vitals | 身体指标（体重/血压/心率等） |
| `exercise` | exercise_log | 运动记录 |
| `sleep` | sleep_log | 睡眠记录 |
| `food` | food_log | 饮食记录 |
| `book` | books | 书籍阅读 |
| `note` | notes | 笔记 |
| `article` | articles | 文章收藏 |
| `task` | tasks | 任务管理 |
| `habit` | habits | 习惯打卡 |
| `goal` | goals | 目标管理 |
| `trip` | trips | 旅行 |
| `place` | places | 地点收藏 |
| `movie` | movies | 电影记录 |
| `life-event` | life_events | 重大事件时间线 |
| `event` | calendar_events | 日历事件 |
| `reminder` | reminders | 提醒 |
| `subscription` | subscriptions | 订阅管理 |
| `time-log` | time_logs | 时间流水（每分钟干了什么） |

## 典型使用流程

```
life> now 起床
life> done
life> spend 5 早餐 food
life> now 上班通勤
life> done
life> diary add              # 写晨间日记
life> task add               # 安排今日任务
life> now 写代码
life> spend 25 午餐 food
life> done
life> time-log list          # 回顾今天时间线
life> transaction list       # 回顾今天消费
```

## 数据库文件

默认生成 `life_data.db`，可用 `sqlite3` 直接查看。

```bash
D:\ProgramData\anaconda3\python.exe -c "
import sqlite3
conn = sqlite3.connect('life_data.db')
for row in conn.execute('SELECT name FROM sqlite_master WHERE type=\"table\" ORDER BY name'):
    print(row[0])
"
```

## 数据备份

直接复制 `life_data.db` 文件即可。
