CREATE VIEW service_tasks AS
SELECT f.name                                                                 AS film_name,
       COALESCE(
               string_agg(a.name, ', ' ORDER BY a.name)
               FILTER (WHERE av.value_date = CURRENT_DATE),
               ''
       )                                                                      AS tasks_today,
       COALESCE(
               string_agg(a.name, ', ' ORDER BY a.name)
               FILTER (WHERE av.value_date = CURRENT_DATE + 20),
               ''
       )                                                                      AS tasks_in_20_days
FROM films f
         INNER JOIN attribute_values av ON av.film_id = f.id
         INNER JOIN attributes a ON av.attribute_id = a.id
         INNER JOIN attribute_types at ON a.attribute_type_id = at.id
WHERE at.name = 'Служебные даты'
  AND av.value_date IN (CURRENT_DATE, CURRENT_DATE + 20)
GROUP BY f.id, f.name;
