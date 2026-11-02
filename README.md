# hw: индексы, кинотеатр

БД в docker: `docker compose up -d`, порт **5433**, user/pass/db — **cinema** / **cinema** / **cinema_db`.

Файлы:
- `main.sql` — таблицы
- `seed_structure.sql` — нормальные данные + сеансы на сегодня, для 5–6 запросов `session_id = 1`
- `seed_text_10000.sql`, `seed_text_10000000.sql` — bulk по movies/clients/theaters
- `queries_homework.sql` — 6 запросов из задания
- `explain_all.sql` — explain analyze для всех шести
- `indexes.sql` — индексы после замеров
- `stats_homework.sql` — pg_stat, размеры
- планы лежат в `plans/`

Неделю считаю по `tickets.sold_at` (поле в main.sql).

## простой / сложный

Сложные: 1–5 (join’ы, в 2 и 4 ещё агрегаты).  
Простой: 6 — min/max по `tickets` на один сеанс.  
В queries_homework внизу закомментированы ещё два однотабличных, если попросят три простых.

## сколько строк

После 10k: movies/clients/theaters ~3336, tickets 528.

После догрузки 10M: в текстовых таблицах ~3.3M строк каждая, tickets всё те же ~528 — bulk гонял только movies/clients/theaters, как в формулировке про текстовые данные. На join’ах по билетам это видно: planner на tickets всё равно seq scan.

## запросы (10k, кратко)

Полный вывод — `plans/queries_sample_10k.txt`.

1. три фильма на сегодня  
2. 378 билетов за 7 дней  
3. афиша, 38 строк  
4. top по выручке — на моих данных в основном «Дюна»  
5. зал на session 1: 20 occupied, остальное free  
6. min 460, max 550  

## планы

Сохранил в:
- `plans/explain_10k.txt`
- `plans/explain_10m_before_index.txt`
- `plans/explain_10m_after_index.txt`

Время (ms, Execution Time из explain):

```
        10k    10M до    10M после indexes
Q1      0.18   0.21      0.24
Q2      0.35   0.61      0.36
Q3      0.30   0.54      0.31
Q4      0.62   0.58      0.61
Q5      0.25   0.20      0.19
Q6      0.06   0.06      0.06
```

Что реально поменялось после indexes.sql:
- Q1, Q3: на sessions был seq scan по дате → bitmap index scan по `idx_sessions_start_time`
- Q5, Q6: seq scan tickets по session_id → bitmap по `idx_tickets_session_sold_at` (первое поле session_id)
- Q2, Q4: по сути без изменений, tickets маленькая таблица

## индексы

В indexes.sql:
- `idx_sessions_start_time` — сеансы «сегодня»
- `idx_tickets_session_id`, `idx_tickets_sold_at`, `idx_tickets_session_sold_at`
- `idx_sessions_movie_id`, `idx_seats_hall_id`
- `idx_tickets_session_seat` — уникальный `(session_id, seat_id)`: одно место на сеанс

В `seed_text_10000.sql` билеты bulk вешаются на три разных места сеанса, поэтому уникальный индекс создаётся.

Параметры postgres в docker не крутил.

## размеры (10M + индексы)

Из `plans/stats.txt` один список: таблицы с индексами (`pg_total_relation_size`) и отдельные индексы, общая сортировка, `LIMIT 15`.
Вверху theaters / clients / movies (~394M / ~393M / ~315M), сразу за ними их primary key (~71–72M). Дальше уже килобитные объекты. Индексы по 16 kB в топ-15 не входят.

По idx_scan после пары прогонов queries: чаще всего primary key на halls/sessions/movies.  
Нули на idx_tickets_session_id, idx_tickets_sold_at и т.д. — таблица маленькая, optimizer не берёт.  
start_time и session_id в составных индексах в explain видно на Q1/Q3/Q5/Q6.

