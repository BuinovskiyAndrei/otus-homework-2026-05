-- Базовая структура и «живые» данные для всех 6 запросов (не текстовый bulk)

INSERT INTO theaters (theater_id, name, location)
VALUES (1, 'Октябрь', 'Москва, Новый Арбат'),
       (2, 'Космос', 'Москва, пр. Мира');

SELECT setval(pg_get_serial_sequence('theaters', 'theater_id'), (SELECT MAX(theater_id) FROM theaters));

INSERT INTO halls (hall_id, theater_id, name, total_seats)
VALUES (1, 1, 'Зал 1', 50),
       (2, 1, 'Зал 2', 80),
       (3, 2, 'Большой зал', 100);

SELECT setval(pg_get_serial_sequence('halls', 'hall_id'), (SELECT MAX(hall_id) FROM halls));

-- Зал 1: 5 рядов × 10 мест
INSERT INTO seats (hall_id, row_number, seat_number)
SELECT 1, row_n, seat_n
FROM generate_series(1, 5) AS row_n
         CROSS JOIN generate_series(1, 10) AS seat_n;

-- Несколько фильмов для сеансов «сегодня» и «за неделю»
INSERT INTO movies (movie_id, title, duration_minutes, genre, release_date)
VALUES (1, 'Дюна: часть вторая', 166, 'фантастика', '2024-03-01'),
       (2, 'Годzilla x Kong', 115, 'боевик', '2024-04-12'),
       (3, 'Паразиты', 132, 'драма', '2019-11-07');

SELECT setval(pg_get_serial_sequence('movies', 'movie_id'), (SELECT MAX(movie_id) FROM movies));

-- session_id = 1 — эталон для запросов 5 и 6 (скриншоты: WHERE session_id = 1)
INSERT INTO sessions (session_id, hall_id, movie_id, start_time, price_base)
VALUES (1, 1, 1, CURRENT_DATE + TIME '18:00', 450.00),
       (2, 1, 2, CURRENT_DATE + TIME '21:00', 500.00),
       (3, 2, 3, CURRENT_DATE + TIME '14:00', 400.00),
       (4, 1, 1, CURRENT_DATE - INTERVAL '3 days' + TIME '19:00', 450.00),
       (5, 2, 2, CURRENT_DATE - INTERVAL '6 days' + TIME '20:00', 480.00),
       (6, 3, 3, CURRENT_DATE + INTERVAL '1 day' + TIME '17:00', 550.00);

SELECT setval(pg_get_serial_sequence('sessions', 'session_id'), (SELECT MAX(session_id) FROM sessions));

INSERT INTO clients (client_id, name, email)
VALUES (1, 'Иван Петров', 'ivan@example.com'),
       (2, 'Мария Сидорова', 'maria@example.com');

SELECT setval(pg_get_serial_sequence('clients', 'client_id'), (SELECT MAX(client_id) FROM clients));

-- Часть мест на сеансе 1 занята (остальные — свободны в запросе 5)
INSERT INTO tickets (session_id, seat_id, client_id, price, sold_at)
SELECT 1,
       s.seat_id,
       (ARRAY [1, 2])[1 + (s.seat_id % 2)],
       450.00 + (s.seat_number * 10),
       CURRENT_TIMESTAMP - INTERVAL '2 days'
FROM seats s
WHERE s.hall_id = 1
  AND s.row_number <= 2;

-- Билеты на сеансы за последнюю неделю (запросы 2 и 4)
INSERT INTO tickets (session_id, seat_id, client_id, price, sold_at)
SELECT 4,
       s.seat_id,
       1,
       450.00,
       CURRENT_TIMESTAMP - INTERVAL '3 days'
FROM seats s
WHERE s.hall_id = 1
  AND s.row_number = 3
LIMIT 15;

INSERT INTO tickets (session_id, seat_id, client_id, price, sold_at)
SELECT 5,
       s.seat_id,
       2,
       480.00,
       CURRENT_TIMESTAMP - INTERVAL '5 days'
FROM seats s
WHERE s.hall_id = 2
  AND s.row_number = 1
LIMIT 20;
