-- Доводит объём строк с текстовыми полями (name, title, genre, location, email) до ~10 000
-- Запускать после main.sql и seed_structure.sql

-- ~3333 фильма
INSERT INTO movies (title, duration_minutes, genre, release_date)
SELECT 'Фильм bulk ' || g,
       90 + (g % 60),
       'жанр-' || (g % 17),
       DATE '2010-01-01' + (g % 5000)
FROM generate_series(1, 3333) AS g;

-- ~3333 клиента
INSERT INTO clients (name, email)
SELECT 'Клиент ' || g,
       'client' || g || '@example.local'
FROM generate_series(1, 3333) AS g;

-- ~3334 строки в theaters (name + location)
INSERT INTO theaters (name, location)
SELECT 'Кинотеатр ' || g,
       'Город ' || (g % 200) || ', ул. Примерная ' || g
FROM generate_series(1, 3334) AS g;

-- Дополнительные сеансы и билеты для нагрузки (не «текст», но нужны для планов)
INSERT INTO sessions (hall_id, movie_id, start_time, price_base)
SELECT 1 + (g % 3),
       1 + (g % 3),
       CURRENT_DATE - ((g % 14) || ' days')::INTERVAL + ((g % 24) || ' hours')::INTERVAL,
       300 + (g % 400)
FROM generate_series(1, 500) AS g;

INSERT INTO tickets (session_id, seat_id, client_id, price, sold_at)
SELECT s.session_id,
       st.seat_id,
       1 + (g % 3333),
       350 + (g % 300),
       CURRENT_TIMESTAMP - ((g % 10) || ' days')::INTERVAL
FROM generate_series(1, 1500) AS g
         JOIN sessions s ON s.session_id = 7 + (g % 500)
         JOIN seats st ON st.hall_id = s.hall_id
    AND st.row_number = 1 + (g % 5)
    AND st.seat_number = 1 + (g % 10);

ANALYZE;

SELECT 'movies' AS tbl, COUNT(*) AS cnt FROM movies
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'theaters', COUNT(*) FROM theaters
UNION ALL SELECT 'tickets', COUNT(*) FROM tickets;
