"""
configs.py - 所有领域实体的配置
每个 EntityConfig 定义了表名、字段、搜索字段等，自动生成 CRUD 命令
"""

from .base import EntityConfig, Field


def all_configs() -> dict[str, EntityConfig]:
    cfgs = {}
    for c in _build_configs():
        cfgs[c.domain] = c
    return cfgs


def get(domain: str) -> EntityConfig | None:
    return all_configs().get(domain)


# ---------------------------------------------------------------------------
#  联系方式
# ---------------------------------------------------------------------------
_contacts = EntityConfig(
    domain="contact", table="contacts", label="Contact", label_plural="Contacts",
    order="updated_at DESC",
    search_fields=["display_name", "nickname", "notes"],
    list_fields=["id", "display_name", "relationship", "is_favorite", "updated_at"],
    fields=[
        Field("display_name", required=True),
        Field("first_name"),
        Field("last_name"),
        Field("nickname"),
        Field("relationship", options=["family", "friend", "colleague", "classmate", "other"]),
        Field("birthday", ftype="date"),
        Field("anniversary", ftype="date"),
        Field("gender", options=["male", "female", "other"]),
        Field("nationality"),
        Field("notes", ftype="textarea"),
        Field("is_favorite", ftype="int", default="0"),
    ])

# ---------------------------------------------------------------------------
#  日记
# ---------------------------------------------------------------------------
_diary = EntityConfig(
    domain="diary", table="diary_entries", label="Diary Entry", label_plural="Diary Entries",
    order="entry_date DESC",
    search_fields=["title", "content"],
    list_fields=["id", "entry_date", "title", "mood_score", "weather"],
    fields=[
        Field("title"),
        Field("content", ftype="textarea", required=True),
        Field("entry_date", ftype="date", required=True),
        Field("entry_time"),
        Field("weather"),
        Field("temperature", ftype="float"),
        Field("mood_score", ftype="int", label="Mood Score (1-10)"),
        Field("is_draft", ftype="int", default="0"),
    ])

# ---------------------------------------------------------------------------
#  情绪记录
# ---------------------------------------------------------------------------
_mood = EntityConfig(
    domain="mood", table="mood_log", label="Mood Log", label_plural="Mood Logs",
    order="log_date DESC",
    list_fields=["id", "log_date", "mood", "score", "note"],
    fields=[
        Field("log_date", ftype="date", required=True),
        Field("log_time"),
        Field("mood", required=True, options=["happy", "sad", "angry", "anxious", "calm", "excited", "tired", "grateful", "stressed", "peaceful"]),
        Field("score", ftype="int", label="Score (1-10)", required=True),
        Field("note", ftype="textarea"),
        Field("triggers", label="Triggers (JSON)"),
    ])

# ---------------------------------------------------------------------------
#  交易
# ---------------------------------------------------------------------------
_transaction = EntityConfig(
    domain="transaction", table="transactions", label="Transaction", label_plural="Transactions",
    order="datetime DESC",
    search_fields=["description", "merchant", "category"],
    list_fields=["id", "datetime", "type", "amount", "category", "description"],
    fields=[
        Field("account_id", label="Account ID (leave empty for 现金)"),
        Field("type", required=True, options=["income", "expense", "transfer"]),
        Field("amount", ftype="float", required=True),
        Field("currency", default="CNY"),
        Field("category", options=["food", "transport", "shopping", "housing", "entertainment", "health", "education", "salary", "investment", "other"]),
        Field("subcategory"),
        Field("datetime", ftype="date", required=True),
        Field("description", ftype="textarea"),
        Field("merchant"),
    ])

# ---------------------------------------------------------------------------
#  财务账户
# ---------------------------------------------------------------------------
_account = EntityConfig(
    domain="account", table="financial_accounts", label="Account", label_plural="Accounts",
    order="sort_order ASC",
    list_fields=["id", "name", "type", "balance", "currency"],
    fields=[
        Field("name", required=True),
        Field("type", required=True, options=["cash", "bank", "credit_card", "investment", "e_wallet", "other"]),
        Field("currency", default="CNY"),
        Field("balance", ftype="float", default="0"),
        Field("institution"),
        Field("account_number", label="Account No (last 4)"),
        Field("is_active", ftype="int", default="1"),
    ])

# ---------------------------------------------------------------------------
#  身体指标
# ---------------------------------------------------------------------------
_vital = EntityConfig(
    domain="vital", table="vitals", label="Vital", label_plural="Vitals",
    order="logged_at DESC",
    list_fields=["id", "logged_at", "weight", "heart_rate", "systolic_bp", "blood_sugar"],
    fields=[
        Field("logged_at", ftype="date", required=True),
        Field("weight", ftype="float", label="Weight (kg)"),
        Field("height", ftype="float", label="Height (cm)"),
        Field("systolic_bp", ftype="int", label="Systolic BP (mmHg)"),
        Field("diastolic_bp", ftype="int", label="Diastolic BP (mmHg)"),
        Field("heart_rate", ftype="int", label="Heart Rate (bpm)"),
        Field("blood_oxygen", ftype="float", label="Blood Oxygen (%)"),
        Field("blood_sugar", ftype="float", label="Blood Sugar (mmol/L)"),
        Field("body_fat", ftype="float", label="Body Fat (%)"),
        Field("temperature", ftype="float", label="Temperature (℃)"),
    ])

# ---------------------------------------------------------------------------
#  运动
# ---------------------------------------------------------------------------
_exercise = EntityConfig(
    domain="exercise", table="exercise_log", label="Exercise", label_plural="Exercises",
    order="date DESC",
    list_fields=["id", "date", "type", "duration", "distance", "calories"],
    fields=[
        Field("date", ftype="date", required=True),
        Field("type", required=True, options=["running", "walking", "cycling", "swimming", "yoga", "gym", "sports", "dancing", "hiking", "other"]),
        Field("duration", ftype="int", label="Duration (min)"),
        Field("distance", ftype="float", label="Distance (km)"),
        Field("calories", ftype="int"),
        Field("heart_rate_avg", ftype="int"),
        Field("heart_rate_max", ftype="int"),
        Field("steps", ftype="int"),
        Field("notes", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  睡眠
# ---------------------------------------------------------------------------
_sleep = EntityConfig(
    domain="sleep", table="sleep_log", label="Sleep Log", label_plural="Sleep Logs",
    order="date DESC",
    list_fields=["id", "date", "duration", "deep_sleep", "quality"],
    fields=[
        Field("date", ftype="date", required=True),
        Field("bed_time", required=True),
        Field("wake_time", required=True),
        Field("duration", ftype="int", label="Total Sleep (min)", required=True),
        Field("deep_sleep", ftype="int", label="Deep Sleep (min)"),
        Field("light_sleep", ftype="int", label="Light Sleep (min)"),
        Field("rem_sleep", ftype="int", label="REM (min)"),
        Field("awakenings", ftype="int"),
        Field("quality", ftype="int", label="Quality (1-10)"),
        Field("notes", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  饮食
# ---------------------------------------------------------------------------
_food = EntityConfig(
    domain="food", table="food_log", label="Food Log", label_plural="Food Logs",
    order="datetime DESC",
    list_fields=["id", "datetime", "meal_type", "food_name", "calories"],
    fields=[
        Field("datetime", ftype="date", required=True),
        Field("meal_type", options=["breakfast", "lunch", "dinner", "snack"]),
        Field("food_name", required=True),
        Field("portion"),
        Field("calories", ftype="int"),
        Field("protein", ftype="float", label="Protein (g)"),
        Field("carbs", ftype="float"),
        Field("fat", ftype="float"),
        Field("fiber", ftype="float"),
        Field("sodium", ftype="float", label="Sodium (mg)"),
        Field("notes", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  书籍
# ---------------------------------------------------------------------------
_book = EntityConfig(
    domain="book", table="books", label="Book", label_plural="Books",
    order="updated_at DESC",
    search_fields=["title", "author", "description"],
    list_fields=["id", "title", "author", "status", "rating"],
    fields=[
        Field("title", required=True),
        Field("author"),
        Field("isbn"),
        Field("publisher"),
        Field("publish_year", ftype="int"),
        Field("pages", ftype="int"),
        Field("description", ftype="textarea"),
        Field("status", options=["wish", "reading", "done", "abandoned"]),
        Field("rating", ftype="float", label="Rating (0-10)"),
        Field("review", ftype="textarea"),
        Field("is_ebook", ftype="int", default="0"),
    ])

# ---------------------------------------------------------------------------
#  笔记
# ---------------------------------------------------------------------------
_note = EntityConfig(
    domain="note", table="notes", label="Note", label_plural="Notes",
    order="updated_at DESC",
    search_fields=["title", "content"],
    list_fields=["id", "title", "notebook", "word_count", "updated_at"],
    fields=[
        Field("title", required=True),
        Field("content", ftype="textarea"),
        Field("notebook", label="Notebook / Folder"),
        Field("is_favorite", ftype="int", default="0"),
        Field("is_archived", ftype="int", default="0"),
        Field("source_url"),
    ])

# ---------------------------------------------------------------------------
#  任务
# ---------------------------------------------------------------------------
_task = EntityConfig(
    domain="task", table="tasks", label="Task", label_plural="Tasks",
    order="created_at DESC",
    search_fields=["title", "description"],
    list_fields=["id", "title", "status", "priority", "due_date"],
    fields=[
        Field("title", required=True),
        Field("description", ftype="textarea"),
        Field("status", options=["todo", "in_progress", "done", "cancelled"]),
        Field("priority", ftype="int", label="Priority (1-5)", default="3"),
        Field("due_date", ftype="date"),
        Field("project_id", label="Project ID"),
        Field("estimated_minutes", ftype="int"),
    ])

# ---------------------------------------------------------------------------
#  习惯
# ---------------------------------------------------------------------------
_habit = EntityConfig(
    domain="habit", table="habits", label="Habit", label_plural="Habits",
    order="created_at DESC",
    search_fields=["name", "description"],
    list_fields=["id", "name", "frequency", "is_active"],
    fields=[
        Field("name", required=True),
        Field("description", ftype="textarea"),
        Field("frequency", required=True, options=["daily", "weekly", "monthly", "custom"]),
        Field("frequency_times", ftype="int", default="1"),
        Field("target_value", ftype="float"),
        Field("unit"),
        Field("is_active", ftype="int", default="1"),
        Field("started_at", ftype="date", required=True),
    ])

# ---------------------------------------------------------------------------
#  旅行
# ---------------------------------------------------------------------------
_trip = EntityConfig(
    domain="trip", table="trips", label="Trip", label_plural="Trips",
    order="start_date DESC",
    search_fields=["name", "description", "notes"],
    list_fields=["id", "name", "start_date", "end_date", "trip_type"],
    fields=[
        Field("name", required=True),
        Field("description", ftype="textarea"),
        Field("start_date", ftype="date", required=True),
        Field("end_date", ftype="date"),
        Field("trip_type", options=["solo", "family", "friends", "business"]),
        Field("budget", ftype="float"),
        Field("currency", default="CNY"),
        Field("notes", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  电影
# ---------------------------------------------------------------------------
_movie = EntityConfig(
    domain="movie", table="movies", label="Movie", label_plural="Movies",
    order="created_at DESC",
    search_fields=["title", "director", "summary"],
    list_fields=["id", "title", "year", "status", "personal_rating"],
    fields=[
        Field("title", required=True),
        Field("original_title"),
        Field("year", ftype="int"),
        Field("director"),
        Field("genre"),
        Field("duration", ftype="int", label="Duration (min)"),
        Field("country"),
        Field("summary", ftype="textarea"),
        Field("status", options=["wish", "watching", "done", "abandoned"]),
        Field("personal_rating", ftype="float", label="Rating (0-10)"),
        Field("review", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  地点
# ---------------------------------------------------------------------------
_place = EntityConfig(
    domain="place", table="places", label="Place", label_plural="Places",
    order="updated_at DESC",
    search_fields=["name", "notes"],
    list_fields=["id", "name", "category", "rating", "is_visited"],
    fields=[
        Field("name", required=True),
        Field("category", options=["restaurant", "cafe", "scenic_spot", "museum", "hotel", "shopping", "park", "other"]),
        Field("rating", ftype="float", label="Rating (0-10)"),
        Field("notes", ftype="textarea"),
        Field("website"),
        Field("phone"),
        Field("is_visited", ftype="int", default="0"),
    ])

# ---------------------------------------------------------------------------
#  重要事件
# ---------------------------------------------------------------------------
_life_event = EntityConfig(
    domain="life-event", table="life_events", label="Life Event", label_plural="Life Events",
    order="date DESC",
    search_fields=["title", "description"],
    list_fields=["id", "date", "title", "category", "significance"],
    fields=[
        Field("title", required=True),
        Field("date", ftype="date", required=True),
        Field("category", options=["education", "career", "family", "relocation", "achievement", "relationship", "health", "other"]),
        Field("description", ftype="textarea"),
        Field("significance", ftype="int", label="Significance (1-10)"),
    ])

# ---------------------------------------------------------------------------
#  提醒
# ---------------------------------------------------------------------------
_reminder = EntityConfig(
    domain="reminder", table="reminders", label="Reminder", label_plural="Reminders",
    order="remind_at ASC",
    list_fields=["id", "title", "remind_at", "is_done"],
    fields=[
        Field("title", required=True),
        Field("note", ftype="textarea"),
        Field("remind_at", ftype="date", required=True),
        Field("is_done", ftype="int", default="0"),
    ])

# ---------------------------------------------------------------------------
#  日历事件
# ---------------------------------------------------------------------------
_event = EntityConfig(
    domain="event", table="calendar_events", label="Calendar Event", label_plural="Calendar Events",
    order="start_datetime DESC",
    search_fields=["title", "description"],
    list_fields=["id", "start_datetime", "title", "category"],
    fields=[
        Field("title", required=True),
        Field("description", ftype="textarea"),
        Field("start_datetime", ftype="date", required=True),
        Field("end_datetime", ftype="date"),
        Field("all_day", ftype="int", default="0"),
        Field("category", options=["personal", "work", "holiday", "birthday", "meeting", "other"]),
        Field("location_name"),
    ])

# ---------------------------------------------------------------------------
#  目标
# ---------------------------------------------------------------------------
_goal = EntityConfig(
    domain="goal", table="goals", label="Goal", label_plural="Goals",
    order="created_at DESC",
    search_fields=["title", "description"],
    list_fields=["id", "title", "type", "status", "progress"],
    fields=[
        Field("title", required=True),
        Field("description", ftype="textarea"),
        Field("type", options=["yearly", "quarterly", "monthly", "lifetime"]),
        Field("status", options=["active", "completed", "abandoned"]),
        Field("start_date", ftype="date", required=True),
        Field("target_date", ftype="date"),
        Field("measurement"),
    ])

# ---------------------------------------------------------------------------
#  订阅
# ---------------------------------------------------------------------------
_subscription = EntityConfig(
    domain="subscription", table="subscriptions", label="Subscription", label_plural="Subscriptions",
    order="next_billing ASC",
    list_fields=["id", "name", "category", "cost", "billing_cycle", "status"],
    fields=[
        Field("name", required=True),
        Field("category", options=["streaming", "cloud", "software", "magazine", "other"]),
        Field("plan"),
        Field("cost", ftype="float"),
        Field("currency", default="CNY"),
        Field("billing_cycle", options=["monthly", "yearly", "quarterly"]),
        Field("next_billing", ftype="date"),
        Field("status", options=["active", "cancelled", "paused"]),
        Field("started_at", ftype="date"),
        Field("notes", ftype="textarea"),
    ])

# ---------------------------------------------------------------------------
#  文章/网页保存
# ---------------------------------------------------------------------------
_article = EntityConfig(
    domain="article", table="articles", label="Article", label_plural="Articles",
    order="created_at DESC",
    search_fields=["title", "summary", "author"],
    list_fields=["id", "title", "source", "status", "read_time"],
    fields=[
        Field("title", required=True),
        Field("url"),
        Field("author"),
        Field("source"),
        Field("summary", ftype="textarea"),
        Field("content", ftype="textarea"),
        Field("status", options=["unread", "reading", "read", "archived"]),
        Field("read_time", ftype="int", label="Read Time (min)"),
        Field("is_favorite", ftype="int", default="0"),
    ])


# ---------------------------------------------------------------------------
#  时间日志（每分钟干了什么）
# ---------------------------------------------------------------------------
_time_log = EntityConfig(
    domain="time-log", table="time_logs", label="Time Log", label_plural="Time Logs",
    order="start_time DESC",
    search_fields=["description", "category"],
    list_fields=["id", "start_time", "end_time", "duration", "category", "description"],
    fields=[
        Field("start_time", required=True),
        Field("end_time"),
        Field("duration", ftype="int", label="Duration (min)"),
        Field("category", options=["work", "study", "leisure", "sleep", "eat", "commute", "exercise", "housework", "social", "reading", "entertainment", "other"]),
        Field("description", ftype="textarea"),
    ])


def _build_configs() -> list[EntityConfig]:
    return [
        _contacts, _diary, _mood,
        _transaction, _account,
        _vital, _exercise, _sleep, _food,
        _book, _note, _article,
        _task, _habit, _goal,
        _trip, _place,
        _movie,
        _life_event, _reminder, _event,
        _subscription, _time_log,
    ]
