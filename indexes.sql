-- Индексы после снятия планов на 10M без оптимизаций (этап «что удалось улучшить»)

CREATE INDEX idx_sessions_start_time ON sessions (start_time);

CREATE INDEX idx_sessions_movie_id ON sessions (movie_id);

CREATE INDEX idx_tickets_session_id ON tickets (session_id);

CREATE INDEX idx_tickets_sold_at ON tickets (sold_at);

CREATE INDEX idx_tickets_session_sold_at ON tickets (session_id, sold_at);

CREATE INDEX idx_seats_hall_id ON seats (hall_id);

-- Уникальность (session_id, seat_id) в seed нарушена bulk-вставкой билетов — перед продом нужна чистка дубликатов:
-- CREATE UNIQUE INDEX idx_tickets_session_seat ON tickets (session_id, seat_id);

ANALYZE;
