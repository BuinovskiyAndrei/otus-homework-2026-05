-- Доводит текстовые строки (~10 млн суммарно по movies + clients + theaters)
-- Запускать на чистой БД после main.sql + seed_structure.sql + seed_text_10000.sql
-- Внимание: может занять десятки минут и несколько ГБ на диске.

INSERT INTO movies (title, duration_minutes, genre, release_date)
SELECT 'Фильм x10m ' || g,
       90 + (g % 60),
       'genre-' || (g % 50),
       DATE '2000-01-01' + (g % 9000)
FROM generate_series(1, 3330000) AS g;

INSERT INTO clients (name, email)
SELECT 'User ' || g || ' ' || md5(g::text),
       'u' || g || '@bulk.example'
FROM generate_series(1, 3330000) AS g;

INSERT INTO theaters (name, location)
SELECT 'Cinema ' || g,
       'Region ' || (g % 5000) || ', address line ' || g || ' extra text padding'
FROM generate_series(1, 3340000) AS g;

ANALYZE;

SELECT 'movies' AS tbl, COUNT(*) AS cnt FROM movies
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'theaters', COUNT(*) FROM theaters;
