with total_entries as(
    select
        'Всего заходов на платформу' as "Название",
        count (case when to_char (entry_at, 'MM') = '01' then 1 end) as "Январь",
        count (case when to_char (entry_at, 'MM') = '02' then 1 end) as "Февраль",
        count (case when to_char (entry_at, 'MM') = '03' then 1 end) as "Март",
        count (case when to_char (entry_at, 'MM') in ('01','02','03') then 1 end) as "Q1",
        count (case when to_char (entry_at, 'MM') = '04' then 1 end) as "Апрель",
        count (case when to_char (entry_at, 'MM') = '05' then 1 end) as "Май",
        count (case when to_char (entry_at, 'MM') = '06' then 1 end) as "Июнь",
        count (case when to_char (entry_at, 'MM') in ('04','05','06') then 1 end) as "Q2",
        count (case when to_char (entry_at, 'MM') = '07' then 1 end) as "Июль",
        count (case when to_char (entry_at, 'MM') = '08' then 1 end) as "Август",
        count (case when to_char (entry_at, 'MM') = '09' then 1 end) as "Сентябрь",
        count (case when to_char (entry_at, 'MM') in ('07','08','09') then 1 end) as "Q3",
        count (case when to_char (entry_at, 'MM') = '10' then 1 end) as "Октябрь",
        count (case when to_char (entry_at, 'MM') = '11' then 1 end) as "Ноябрь",
        count (case when to_char (entry_at, 'MM') = '12' then 1 end) as "Декабрь",
        count (case when to_char (entry_at, 'MM') in ('10','11','12') then 1 end) as "Q4"
    from userentry
    where true 
		and to_char(entry_at, 'YYYY') = {{year}}
),
unique_entries as (
    select 
        'Уникальных' as "Название",
        count (distinct case when to_char (entry_at, 'MM') = '01' then user_id end) as "Январь",
        count (distinct case when to_char (entry_at, 'MM') = '02' then user_id end) as "Февраль",
        count (distinct case when to_char (entry_at, 'MM') = '03' then user_id end) as "Март",
        count (distinct case when to_char (entry_at, 'MM') in ('01','02','03') then user_id end) as "Q1",
        count (distinct case when to_char (entry_at, 'MM') = '04' then user_id end) as "Апрель",
        count (distinct case when to_char (entry_at, 'MM') = '05' then user_id end) as "Май",
        count (distinct case when to_char (entry_at, 'MM') = '06' then user_id end) as "Июнь",
        count (distinct case when to_char (entry_at, 'MM') in ('04','05','06') then user_id end) as "Q2",
        count (distinct case when to_char (entry_at, 'MM') = '07' then user_id end) as "Июль",
        count (distinct case when to_char (entry_at, 'MM') = '08' then user_id end) as "Август",
        count (distinct case when to_char (entry_at, 'MM') = '09' then user_id end) as "Сентябрь",
        count (distinct case when to_char (entry_at, 'MM') in ('07','08','09') then user_id end) as "Q3",
        count (distinct case when to_char (entry_at, 'MM') = '10' then user_id end) as "Октябрь",
        count (distinct case when to_char (entry_at, 'MM') = '11' then user_id end) as "Ноябрь",
        count (distinct case when to_char (entry_at, 'MM') = '12' then user_id end) as "Декабрь",
        count (distinct case when to_char (entry_at, 'MM') in ('10','11','12') then user_id end) as "Q4"
    from userentry 
    where true 
		and to_char(entry_at, 'YYYY') = {{year}}
 ),
tries as(
    select 
        created_at, problem_id, user_id
    from coderun cr 
    union all
    select 
        created_at, problem_id, user_id
    from codesubmit cs
),
tries_result as (
    select 
        'Попыток решения задач' as "Название",
        count (case when to_char (created_at, 'MM') = '01' then problem_id end) as "Январь",
        count (case when to_char (created_at, 'MM') = '02' then problem_id end) as "Февраль",
        count (case when to_char (created_at, 'MM') = '03' then problem_id end) as "Март",
        count (case when to_char (created_at, 'MM') in ('01','02','03') then problem_id end) as "Q1",
        count (case when to_char (created_at, 'MM') = '04' then problem_id end) as "Апрель",
        count (case when to_char (created_at, 'MM') = '05' then problem_id end) as "Май",
        count (case when to_char (created_at, 'MM') = '06' then problem_id end) as "Июнь",
        count (case when to_char (created_at, 'MM') in ('04','05','06') then problem_id end) as "Q2",
        count (case when to_char (created_at, 'MM') = '07' then problem_id end) as "Июль",
        count (case when to_char (created_at, 'MM') = '08' then problem_id end) as "Август",
        count (case when to_char (created_at, 'MM') = '09' then problem_id end) as "Сентябрь",
        count (case when to_char (created_at, 'MM') in ('07','08','09') then problem_id end) as "Q3",
        count (case when to_char (created_at, 'MM') = '10' then problem_id end) as "Октябрь",
        count (case when to_char (created_at, 'MM') = '11' then problem_id end) as "Ноябрь",
        count (case when to_char (created_at, 'MM') = '12' then problem_id end) as "Декабрь",
        count (case when to_char (created_at, 'MM') in ('10','11','12') then problem_id end) as "Q4"
    from tries
    where true 
		and to_char(created_at, 'YYYY') = {{year}}
),
successful_tries as (
    select
        'Успешных попыток' as "Название",
        count (case when to_char (created_at, 'MM') = '01' then 1 end) as "Январь",
        count (case when to_char (created_at, 'MM') = '02' then 1 end) as "Февраль",
        count (case when to_char (created_at, 'MM') = '03' then 1 end) as "Март",
        count (case when to_char (created_at, 'MM') in ('01','02','03') then 1 end) as "Q1",
        count (case when to_char (created_at, 'MM') = '04' then 1 end) as "Апрель",
        count (case when to_char (created_at, 'MM') = '05' then 1 end) as "Май",
        count (case when to_char (created_at, 'MM') = '06' then 1 end) as "Июнь",
        count (case when to_char (created_at, 'MM') in ('04','05','06') then 1 end) as "Q2",
        count (case when to_char (created_at, 'MM') = '07' then 1 end) as "Июль",
        count (case when to_char (created_at, 'MM') = '08' then 1 end) as "Август",
        count (case when to_char (created_at, 'MM') = '09' then 1 end) as "Сентябрь",
        count (case when to_char (created_at, 'MM') in ('07','08','09') then 1 end) as "Q3",
        count (case when to_char (created_at, 'MM') = '10' then 1 end) as "Октябрь",
        count (case when to_char (created_at, 'MM') = '11' then 1 end) as "Ноябрь",
        count (case when to_char (created_at, 'MM') = '12' then 1 end) as "Декабрь",
        count (case when to_char (created_at, 'MM') in ('10','11','12') then 1 end) as "Q4"
    from codesubmit
    where true 
		and is_false = 0
		and to_char(created_at, 'YYYY') = {{year}}
),
cnt_problems_per_user as (
    select
        user_id,
        count (distinct case when to_char (created_at, 'MM') = '01' then problem_id end) as "Январь",
        count (distinct case when to_char (created_at, 'MM') = '02' then problem_id end) as "Февраль",
        count (distinct case when to_char (created_at, 'MM') = '03' then problem_id end) as "Март",
        count (distinct case when to_char (created_at, 'MM')  in ('01','02','03') then problem_id end) as "Q1",
        count (distinct case when to_char (created_at, 'MM') = '04' then problem_id end) as "Апрель",
        count (distinct case when to_char (created_at, 'MM') = '05' then problem_id end) as "Май",
        count (distinct case when to_char (created_at, 'MM') = '06' then problem_id end) as "Июнь",
        count (distinct case when to_char (created_at, 'MM')  in ('04','05','06') then problem_id end) as "Q2",
        count (distinct case when to_char (created_at, 'MM') = '07' then problem_id end) as "Июль",
        count (distinct case when to_char (created_at, 'MM') = '08' then problem_id end) as "Август",
        count (distinct case when to_char (created_at, 'MM') = '09' then problem_id end) as "Сентябрь",
        count (distinct case when to_char (created_at, 'MM')  in ('07','08','09') then problem_id end) as "Q3",
        count (distinct case when to_char (created_at, 'MM') = '10' then problem_id end) as "Октябрь",
        count (distinct case when to_char (created_at, 'MM') = '11' then problem_id end) as "Ноябрь",
        count (distinct case when to_char (created_at, 'MM') = '12' then problem_id end) as "Декабрь",
        count (distinct case when to_char (created_at, 'MM')  in ('10','11','12') then problem_id end) as "Q4"
    from codesubmit
    where true 
    	and is_false = 0
		and to_char(created_at, 'YYYY') = {{year}}
group by user_id
),
solved_problems as (
    select 
        'Успешно решенных задач' as "Название",
        sum ("Январь") as "Январь",
        sum ("Февраль") as "Февраль",
        sum ("Март") as "Март",
        sum ("Январь") + sum ("Февраль") + sum ("Март") as "Q1",
        sum ("Апрель") as "Апрель",
        sum ("Май") as "Май",
        sum ("Июнь") as "Июнь",
        sum ("Апрель") + sum ("Май") + sum ("Июнь") as "Q2",
        sum ("Июль") as "Июль",
        sum ("Август") as "Август",
        sum ("Сентябрь") as "Сентябрь",
        sum ("Июль") + sum ("Август") + sum ("Сентябрь") as "Q3",
        sum ("Октябрь") as "Октябрь",
        sum ("Ноябрь") as "Ноябрь",
        sum ("Декабрь") as "Декабрь",
        sum ("Октябрь") + sum ("Ноябрь") + sum ("Декабрь") as "Q4"
    from cnt_problems_per_user
)
select
    *
from total_entries
union all
select
    *
from unique_entries
union all
select
    *
from tries_result
union all
select
    *
from successful_tries
union all
select
    *
from solved_problems
