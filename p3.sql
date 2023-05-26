CREATE TABLE articles (
    id serial primary key,
    title text not null,
    publication text not null,
    author text not null,
    date text not null,
    year int not null,
    month int not null,
    url text not null,
    content text not null,
);

-- problemas con la carga del csv 

select setweight(to_tsvector('english', title), 'A')
       ||
   setweight(to_tsvector('english', content), 'B')
from articles;

alter table articles add column indexado tsvector;

update articles set indexado = T.indexado
from (
select id,
   setweight(to_tsvector('english', title), 'A')   ||
   setweight(to_tsvector('english', content), 'B')
   as indexado
from articles
) AS T
where articles.id = T.id;

create index indexado_gin_idx on articles using gin(indexado);


explain analyze
select title, content from articles
  where content ilike '%man%' or content ilike '%woman%';

explain analyze
select title, CONTENT from film
 where to_tsquery('english', 'Man | Woman') @@ indexado;

-- top k indexado
explain analyze
select title, content, 
       ts_rank_cd(indexado, query) as rank
 from film, to_tsquery('english', 'Man | Woman') query 
 where query @@ indexado
 order by rank desc

 
 -- top k sin indexar
explain analyze
select title, content, 
       ts_rank_cd(to_tsvector(content) || to_tsvector(title), query) as rank
 from film, to_tsquery('english', 'Man | Woman') query 
 order by rank desc
 limit 2;--2,4,8,16,32,64
 
 
 
