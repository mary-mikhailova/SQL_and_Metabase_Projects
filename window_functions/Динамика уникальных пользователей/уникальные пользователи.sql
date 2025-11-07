with un as(
select user_id, to_char(created_at, 'YYYY-MM-DD') as ymd
    from codesubmit c
    where created_at >= '2022-01-01'
    union
    select user_id, to_char(created_at, 'YYYY-MM-DD')
    from coderun c2
    where created_at >= '2022-01-01'
), 
numm as (select 
ymd,
row_number () over (partition by user_id order by ymd) as num
from un
),
unique_days as (
    select 
        ymd,
        sum(case when num = 1 then 1 else 0 end) as daily_unique_cnt
    from numm
    group by ymd
  )
select 
    ymd,
    sum(daily_unique_cnt) over (order by ymd)::integer as unique_cnt
from unique_days
order by ymd 
