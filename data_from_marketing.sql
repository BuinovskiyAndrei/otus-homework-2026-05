CREATE VIEW marketing_data AS
SELECT f.name  AS film_name,
       at.name AS attribute_type,
       a.name  AS attribute_name,
       COALESCE(
               av.value_text,
               TO_CHAR(av.value_date, 'YYYY-MM-DD'),
               av.value_integer::TEXT,
               CASE
                   WHEN av.value_decimal IS NOT NULL THEN trim_scale(av.value_decimal)::TEXT
                   END,
               CASE
                   WHEN av.value_boolean IS NOT NULL THEN
                       CASE WHEN av.value_boolean THEN 'Да' ELSE 'Нет' END
                   END
       )       AS attribute_value
FROM attribute_values av
         INNER JOIN attributes a ON av.attribute_id = a.id
         INNER JOIN attribute_types at ON a.attribute_type_id = at.id
         INNER JOIN films f ON av.film_id = f.id;
