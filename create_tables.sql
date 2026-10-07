-- Таблица "Фильмы"
CREATE TABLE films
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица "Типы атрибутов"
CREATE TABLE attribute_types
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Таблица "Атрибуты"
CREATE TABLE attributes
(
    id                SERIAL PRIMARY KEY,
    attribute_type_id INT          NOT NULL REFERENCES attribute_types (id),
    name              VARCHAR(255) NOT NULL,
    value_kind        VARCHAR(20)  NOT NULL
        CONSTRAINT attributes_value_kind_chk
            CHECK (value_kind IN ('text', 'boolean', 'date', 'integer', 'decimal'))
);

-- Таблица "Значения" (typed EAV: тип колонки соответствует value_kind атрибута)
CREATE TABLE attribute_values
(
    id             SERIAL PRIMARY KEY,
    film_id        INT     NOT NULL REFERENCES films (id),
    attribute_id   INT     NOT NULL REFERENCES attributes (id),
    value_text     TEXT,
    value_date     DATE,
    value_boolean  BOOLEAN,
    value_integer  BIGINT,
    value_decimal  NUMERIC(12, 4),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT attribute_values_single_value_chk
        CHECK (num_nonnulls(value_text, value_date, value_boolean, value_integer, value_decimal) = 1)
);

CREATE UNIQUE INDEX idx_attribute_values_film_attribute
    ON attribute_values (film_id, attribute_id);

CREATE INDEX idx_attribute_values_film_id
    ON attribute_values (film_id);

CREATE INDEX idx_attribute_values_attribute_id
    ON attribute_values (attribute_id);

CREATE INDEX idx_attribute_values_value_date
    ON attribute_values (value_date);

CREATE INDEX idx_attributes_attribute_type_id
    ON attributes (attribute_type_id);
