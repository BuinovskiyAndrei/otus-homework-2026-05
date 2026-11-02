-- Планы выполнения для всех 6 запросов (копировать вывод в README / plans/)
-- Запуск: psql ... -f explain_all.sql > plans/after_10k.txt

ANALYZE;

\echo '========== Q1 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT DISTINCT m.movie_id, m.title, m.duration_minutes, m.genre
FROM movies m
         INNER JOIN sessions s ON s.movie_id = m.movie_id
WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY m.title;

\echo '========== Q2 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT COUNT(*) AS tickets_sold_last_7_days
FROM tickets t
         INNER JOIN sessions s ON s.session_id = t.session_id
WHERE t.sold_at >= CURRENT_TIMESTAMP - INTERVAL '7 days';

\echo '========== Q3 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT m.title, s.start_time, h.name AS hall_name, th.name AS theater_name, s.price_base
FROM sessions s
         INNER JOIN movies m ON m.movie_id = s.movie_id
         INNER JOIN halls h ON h.hall_id = s.hall_id
         INNER JOIN theaters th ON th.theater_id = h.theater_id
WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY s.start_time;

\echo '========== Q4 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT m.title, SUM(t.price) AS total_revenue
FROM tickets t
         INNER JOIN sessions s ON t.session_id = s.session_id
         INNER JOIN movies m ON s.movie_id = m.movie_id
WHERE t.sold_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
GROUP BY m.movie_id, m.title
ORDER BY total_revenue DESC
LIMIT 3;

\echo '========== Q5 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT st.row_number, st.seat_number,
       CASE WHEN tk.ticket_id IS NULL THEN 'free' ELSE 'occupied' END AS seat_status
FROM sessions s
         INNER JOIN seats st ON st.hall_id = s.hall_id
         LEFT JOIN tickets tk ON tk.seat_id = st.seat_id AND tk.session_id = s.session_id
WHERE s.session_id = 1
ORDER BY st.row_number, st.seat_number;

\echo '========== Q6 =========='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT MIN(price) AS min_ticket_price, MAX(price) AS max_ticket_price
FROM tickets
WHERE session_id = 1;
