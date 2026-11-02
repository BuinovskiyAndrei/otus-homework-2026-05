-- =============================================================================
-- 6 запросов домашнего задания (порядок = номер в отчёте)
-- Перед EXPLAIN на каждом этапе: ANALYZE;
-- Для планов: EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) <запрос>;
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1. Фильмы, которые идут сегодня [сложный: JOIN]
-- -----------------------------------------------------------------------------
SELECT DISTINCT m.movie_id,
                m.title,
                m.duration_minutes,
                m.genre
FROM movies m
         INNER JOIN sessions s ON s.movie_id = m.movie_id
WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY m.title;

-- -----------------------------------------------------------------------------
-- Q2. Количество проданных билетов за последние 7 дней [сложный: JOIN + агрегат]
-- sold_at — дата продажи
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS tickets_sold_last_7_days
FROM tickets t
         INNER JOIN sessions s ON s.session_id = t.session_id
WHERE t.sold_at >= CURRENT_TIMESTAMP - INTERVAL '7 days';

-- -----------------------------------------------------------------------------
-- Q3. Афиша на сегодня [сложный: JOIN]
-- -----------------------------------------------------------------------------
SELECT m.title,
       s.start_time,
       h.name  AS hall_name,
       th.name AS theater_name,
       s.price_base
FROM sessions s
         INNER JOIN movies m ON m.movie_id = s.movie_id
         INNER JOIN halls h ON h.hall_id = s.hall_id
         INNER JOIN theaters th ON th.theater_id = h.theater_id
WHERE s.start_time >= CURRENT_DATE
  AND s.start_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY s.start_time;

-- -----------------------------------------------------------------------------
-- Q4. Три самых прибыльных фильма за неделю [сложный: JOIN + GROUP BY]
-- -----------------------------------------------------------------------------
SELECT m.title,
       SUM(t.price) AS total_revenue
FROM tickets t
         INNER JOIN sessions s ON t.session_id = s.session_id
         INNER JOIN movies m ON s.movie_id = m.movie_id
WHERE t.sold_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
GROUP BY m.movie_id, m.title
ORDER BY total_revenue DESC
LIMIT 3;

-- -----------------------------------------------------------------------------
-- Q5. Схема зала: свободные и занятые места на сеанс [сложный: JOIN]
-- Для скриншотов: session_id = 1 (создаётся в seed_structure.sql)
-- -----------------------------------------------------------------------------
SELECT st.row_number,
       st.seat_number,
       CASE
           WHEN tk.ticket_id IS NULL THEN 'free'
           ELSE 'occupied'
           END AS seat_status
FROM sessions s
         INNER JOIN seats st ON st.hall_id = s.hall_id
         LEFT JOIN tickets tk ON tk.seat_id = st.seat_id AND tk.session_id = s.session_id
WHERE s.session_id = 1
ORDER BY st.row_number, st.seat_number;

-- -----------------------------------------------------------------------------
-- Q6. Min / max цена билета на сеанс [простой: одна таблица]
-- session_id = 1
-- -----------------------------------------------------------------------------
SELECT MIN(price) AS min_ticket_price,
       MAX(price) AS max_ticket_price
FROM tickets
WHERE session_id = 1;

-- -----------------------------------------------------------------------------
-- Дополнительно «простые» для требования 3+3 (если проверяющий просит явно):
-- Q7. Сеансы только на сегодня [простой: sessions]
-- Q8. Число билетов на сеанс [простой: tickets]
-- -----------------------------------------------------------------------------
-- SELECT session_id, hall_id, movie_id, start_time, price_base
-- FROM sessions
-- WHERE start_time >= CURRENT_DATE
--   AND start_time < CURRENT_DATE + INTERVAL '1 day';
--
-- SELECT COUNT(*) AS tickets_on_session FROM tickets WHERE session_id = 1;
