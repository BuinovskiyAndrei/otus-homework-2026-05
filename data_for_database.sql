-- Заполняем фильмы
INSERT INTO films (name)
VALUES ('Соник'),
       ('Соник 2');

-- Заполняем типы атрибутов
INSERT INTO attribute_types (name)
VALUES ('Рецензии'),
       ('Премия'),
       ('Важные даты'),
       ('Служебные даты');

-- Заполняем атрибуты (value_kind задаёт колонку хранения в attribute_values)
INSERT INTO attributes (attribute_type_id, name, value_kind)
VALUES (1, 'Рецензия критиков', 'text'),
       (1, 'Отзыв неизвестной киноакадемии', 'text'),
       (1, 'Средний рейтинг критиков', 'decimal'),
       (2, 'Оскар', 'boolean'),
       (2, 'Ника', 'boolean'),
       (3, 'Мировая премьера', 'date'),
       (3, 'Премьера в РФ', 'date'),
       (4, 'Начало продажи билетов', 'date'),
       (4, 'Запуск рекламы на ТВ', 'date');

-- Заполняем значения (служебные даты привязаны к CURRENT_DATE для проверки service_tasks)
INSERT INTO attribute_values (film_id, attribute_id, value_text, value_date, value_boolean, value_integer, value_decimal)
VALUES (1, 1, 'Фильм блестящий!', NULL, NULL, NULL, NULL),
       (1, 3, NULL, NULL, NULL, NULL, 8.7500),
       (1, 4, NULL, NULL, TRUE, NULL, NULL),
       (1, 6, NULL, '2025-01-15', NULL, NULL, NULL),
       (1, 8, NULL, CURRENT_DATE, NULL, NULL, NULL),
       (1, 9, NULL, CURRENT_DATE + 20, NULL, NULL, NULL),
       (2, 2, 'Неоднозначный отзыв', NULL, NULL, NULL, NULL),
       (2, 3, NULL, NULL, NULL, NULL, 6.5000),
       (2, 5, NULL, NULL, TRUE, NULL, NULL),
       (2, 7, NULL, '2025-02-01', NULL, NULL, NULL),
       (2, 8, NULL, CURRENT_DATE + 20, NULL, NULL, NULL),
       (2, 9, NULL, CURRENT_DATE, NULL, NULL, NULL);
