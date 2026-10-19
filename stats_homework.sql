-- Топ-15 объектов по размеру (таблицы с индексами) и индексы отдельно

SELECT c.relname AS object_name,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
       pg_total_relation_size(c.oid) AS total_bytes
FROM pg_class c
         JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
ORDER BY total_bytes DESC
LIMIT 15;

SELECT indexrelname AS index_name,
       relname AS table_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       pg_relation_size(indexrelid) AS index_bytes
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC
LIMIT 15;

-- 5 самых используемых индексов (idx_scan > 0 после прогона всех запросов)
SELECT schemaname,
       relname AS table_name,
       indexrelname AS index_name,
       idx_scan,
       idx_tup_read
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 5;

-- 5 наименее используемых (часто idx_scan = 0; сортировка по размеру индекса)
SELECT schemaname,
       relname AS table_name,
       indexrelname AS index_name,
       idx_scan,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC, pg_relation_size(indexrelid) DESC
LIMIT 5;
