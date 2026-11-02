-- См. Q4 в queries_homework.sql (топ-3 за неделю)
SELECT m.title,
       SUM(t.price) AS total_revenue
FROM tickets t
         INNER JOIN sessions s ON t.session_id = s.session_id
         INNER JOIN movies m ON s.movie_id = m.movie_id
WHERE t.sold_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
GROUP BY m.movie_id, m.title
ORDER BY total_revenue DESC
LIMIT 3;
