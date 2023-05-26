select setweight(to_tsvector('english', title), 'A')
       ||
   setweight(to_tsvector('english', description), 'B')
from film;
alter table film add column indexado tsvector;
update film set indexado = T.indexado
from (
select film_id,
   setweight(to_tsvector('english', title), 'A')   ||
   setweight(to_tsvector('english', description), 'B')
   as indexado
from film
) AS T
where film.film_id = T.film_id;
create index indexado_gin_idx on film using gin(indexado);
-- 5.056 ms
explain analyze
select title, description from film
  where description ilike '%man%' or description ilike '%woman%';
-- 0.376 ms
explain analyze
select title, description from film
 where to_tsquery('english', 'Man | Woman') @@ indexado;

-- top k indexado
explain analyze
select title, description, 
       ts_rank_cd(indexado, query) as rank
 from film, to_tsquery('english', 'Man | Woman') query 
 where query @@ indexado
 order by rank desc
 limit 64;--2,4,8,16,32,64
 
 -- 2 1.698
 -- 4 1.833
 -- 8 2.162
 -- 16 2.365
 -- 32 2.413
 -- 64 2.362
 
 -- top k sin indexar
explain analyze
select title, description, 
       ts_rank_cd(to_tsvector(description) || to_tsvector(title), query) as rank
 from film, to_tsquery('english', 'Man | Woman') query 
 order by rank desc
 limit 2;--2,4,8,16,32,64
 
 -- 2 61.524
 -- 4 52.635
 -- 8 42.860
 -- 16 59.202
 -- 32 52.453
 -- 64 43.307
 
 

 
 