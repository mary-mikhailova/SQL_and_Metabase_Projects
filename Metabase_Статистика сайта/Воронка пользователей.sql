with date_filter as (
    select * 
    from stat
    where true
        and {{created_at}}
),
action_name as (
    select
        created_at,
        case 
            when event = 'enter_site' then '1. Зашел на сайт'
            when event = 'open_page' then '2. Открыл страницу'
            when event = 'request_consultation' then '3. Оставил заявку на консультацию'
            when event = 'request_demo' then '4. Запросил демо'
            when event = 'go_to_payment' then '5. Перешел к оплате'
            when event = 'get_test_results' then '6. Запросил результатытеста'
        end event_description,
        case 
            when url_params like '%discount=%' then
            substring (url_params from 'discount=[^&]*')
            when url_params like '%utm_source=%' then
            substring (url_params from 'utm_source=[^&]*')
            when url_params like '%funnel=%' then
            substring (url_params from 'funnel=[^&]*')
            when url_params like '%source=%' and url_params not like '%utm_source%' then
            substring (url_params from 'source=[^&]*')
    	end params
    from date_filter
),
result_cnt as (
    select 
        params, 
        event_description,
        count (*) as event_cnt
    from action_name
    group by params, event_description
),
param_filters as (
    select *
    from result_cnt
    where true
    [[and params = {{params}}]] 
    )
select  
    event_description,
    sum (event_cnt) as "Количество событий"
from param_filters
where true 
    and event_description is not null
group by event_description
order by event_description
