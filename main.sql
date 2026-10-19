-- Схема БД «Кинотеатр» (PostgreSQL, идентификаторы в нижнем регистре)

CREATE TABLE theaters (
    theater_id   SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    location     VARCHAR(255)
);

CREATE TABLE halls (
    hall_id      SERIAL PRIMARY KEY,
    theater_id   INT          NOT NULL REFERENCES theaters (theater_id),
    name         VARCHAR(50)  NOT NULL,
    total_seats  INT          NOT NULL
);

CREATE TABLE movies (
    movie_id           SERIAL PRIMARY KEY,
    title              VARCHAR(100) NOT NULL,
    duration_minutes   INT          NOT NULL,
    genre              VARCHAR(50),
    release_date       DATE
);

CREATE TABLE sessions (
    session_id   SERIAL PRIMARY KEY,
    hall_id      INT            NOT NULL REFERENCES halls (hall_id),
    movie_id     INT            NOT NULL REFERENCES movies (movie_id),
    start_time   TIMESTAMP      NOT NULL,
    price_base   DECIMAL(10, 2) NOT NULL
);

CREATE TABLE seats (
    seat_id      SERIAL PRIMARY KEY,
    hall_id      INT NOT NULL REFERENCES halls (hall_id),
    row_number   INT NOT NULL,
    seat_number  INT NOT NULL,
    UNIQUE (hall_id, row_number, seat_number)
);

CREATE TABLE clients (
    client_id  SERIAL PRIMARY KEY,
    name       VARCHAR(100),
    email      VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id   SERIAL PRIMARY KEY,
    session_id  INT            NOT NULL REFERENCES sessions (session_id),
    seat_id     INT            NOT NULL REFERENCES seats (seat_id),
    client_id   INT REFERENCES clients (client_id),
    price       DECIMAL(10, 2) NOT NULL,
    sold_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Для отчёта: сеанс с фиксированным id=1 (схема зала, min/max цены) создаётся в seed_structure.sql
