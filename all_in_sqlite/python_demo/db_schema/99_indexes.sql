-- ============================================================
-- 99_indexes.sql - 常用索引（提升查询性能）
-- ============================================================

-- 通用索引
CREATE INDEX IF NOT EXISTS idx_taggings_target ON taggings(target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_attachments_target ON attachments(target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_links_target ON links(target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_ratings_target ON ratings(target_id, target_type);

-- 联系人
CREATE INDEX IF NOT EXISTS idx_contacts_deleted ON contacts(deleted_at);
CREATE INDEX IF NOT EXISTS idx_contact_methods_contact ON contact_methods(contact_id);
CREATE INDEX IF NOT EXISTS idx_contact_interactions_contact ON contact_interactions(contact_id);
CREATE INDEX IF NOT EXISTS idx_contact_interactions_datetime ON contact_interactions(datetime);

-- 日记
CREATE INDEX IF NOT EXISTS idx_diary_entries_date ON diary_entries(entry_date);
CREATE INDEX IF NOT EXISTS idx_diary_entries_deleted ON diary_entries(deleted_at);
CREATE INDEX IF NOT EXISTS idx_mood_log_date ON mood_log(log_date);

-- 财务
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_datetime ON transactions(datetime);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);
CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category);

-- 健康
CREATE INDEX IF NOT EXISTS idx_vitals_logged_at ON vitals(logged_at);
CREATE INDEX IF NOT EXISTS idx_exercise_log_date ON exercise_log(date);
CREATE INDEX IF NOT EXISTS idx_sleep_log_date ON sleep_log(date);
CREATE INDEX IF NOT EXISTS idx_food_log_datetime ON food_log(datetime);

-- 知识
CREATE INDEX IF NOT EXISTS idx_notes_updated ON notes(updated_at);
CREATE INDEX IF NOT EXISTS idx_notes_deleted ON notes(deleted_at);
CREATE INDEX IF NOT EXISTS idx_books_status ON books(status);
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(status);
CREATE INDEX IF NOT EXISTS idx_flashcards_next_review ON flashcards(next_review_at);

-- 媒体
CREATE INDEX IF NOT EXISTS idx_movies_status ON movies(status);
CREATE INDEX IF NOT EXISTS idx_tv_shows_status ON tv_shows(status);

-- 任务
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_due ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_habit_logs_date ON habit_logs(log_date);
CREATE INDEX IF NOT EXISTS idx_time_logs_start ON time_logs(start_time);

-- 旅行
CREATE INDEX IF NOT EXISTS idx_trip_destinations_trip ON trip_destinations(trip_id);
CREATE INDEX IF NOT EXISTS idx_checkins_datetime ON checkins(datetime);

-- 通讯
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sent_at ON messages(sent_at);
CREATE INDEX IF NOT EXISTS idx_emails_thread ON emails(thread_id);
CREATE INDEX IF NOT EXISTS idx_emails_sent_at ON emails(sent_at);

-- 日历
CREATE INDEX IF NOT EXISTS idx_calendar_events_start ON calendar_events(start_datetime);
CREATE INDEX IF NOT EXISTS idx_life_events_date ON life_events(date);
CREATE INDEX IF NOT EXISTS idx_reminders_remind_at ON reminders(remind_at);
