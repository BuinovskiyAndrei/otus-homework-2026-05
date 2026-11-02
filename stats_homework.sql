-- Топ-15 объектов: таблицы вместе с индексами и отдельные индексы, одна сортировка
SELECT object_name,
       object_kind,
       pg_size_pretty(size_bytes) AS size,
       size_bytes
FROM (
         SELECT c.relname AS object_name,
                'table' AS object_kind,
                pg_total_relation_size(c.oid) AS size_bytes
         FROM pg_class c
                  JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE n.nspname = 'public'
           AND c.relkind = 'r'
         UNION ALL
         SELECT indexrelname,
                'index',
                pg_relation_size(indexrelid)
         FROM pg_stat_user_indexes
     ) objects
ORDER BY size_bytes DESC
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
