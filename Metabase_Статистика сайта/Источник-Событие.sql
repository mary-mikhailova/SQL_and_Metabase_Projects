with all_data as (
    select 
        substring (url_params from 'discount=[^&]*') as params,
        event
    from stat
    where url_params like '%discount=%'
    [[and created_at between {{date1}} and {{date2}}]]
    union all
    select 
        substring(url_params FROM 'utm_source=[^&]*')as params,
        event
    from stat
    where url_params LIKE '%utm_source=%'
    [[and created_at between {{date1}} and {{date2}}]]
    union all
    select 
        substring(url_params FROM 'funnel=[^&]*')as params,
        event
    from stat
    where url_params LIKE '%funnel=%'
    [[and created_at between {{date1}} and {{date2}}]]
    union all
    select 
        substring (url_params from 'source=[^&]*') as params,
        event
    from stat
    where url_params like '%source=%' and url_params not like '%utm_source%'
    [[and created_at between {{date1}} and {{date2}}]]
)
select 
    params,
    event,
    count (*) as cnt 
from all_data
group by params, event
order by params, event
