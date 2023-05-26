--CREATE EXTENSION pg_trgm;

delete from articles;

INSERT INTO articles(body)
SELECT
md5(random()::text)
from (
SELECT * FROM generate_series(1,1000000) AS id
) AS x;

INSERT INTO articles(body)
SELECT
md5(random()::text)
from (
	SELECT * FROM generate_series(1,1000000) AS id
) AS x;
update articles set body_indexed = body;

select * from articles;

DROP INDEX articles_search_idx;
CREATE INDEX articles_search_idx ON articles USING gin
(body_indexed gin_trgm_ops);

explain analyze SELECT count(*) FROM articles where body ilike '%abc%';
explain analyze SELECT count(*) FROM articles where body_indexed ilike'%abc%';

-- 1000 6.142 0.183
-- 10000 66.789 1.055
-- 100000 289.251 10.510
-- 1000000 2289.626 257.128