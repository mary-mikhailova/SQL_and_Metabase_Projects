with data_filter as (
    select *
    from bonuscheques
    where true
    and {{datetime}}
    and {{shop}}
),
date_card as (
	select max (datetime::date) as max_date, card
	from data_filter
	where card !~ '[A-Za-z]' and CHAR_LENGTH(card)=13
	group by card
	order by max_date desc
),
--выбираем дату самой поздней покупки для каждого пользователя (карты), при этом исключаем карты, которые содержат буквы и обозначаем, 
--что номер карты должен содержать ровно 13 символов
f_m_card as (
	select card, COUNT(*) as f, AVG(summ) as m
	from data_filter
	where card !~ '[A-Za-z]' and CHAR_LENGTH(card)=13
	group by card
),
--для каждой карты считаем количество строк (транзакций) и находим средний чек
rfm_data as (
	select date_card.card, 
	first_value (date_card.max_date) over (order by max_date desc) - date_card.max_date as r, 
	f_m_card.f,
	round (f_m_card.m,0) as m
	from date_card
		join f_m_card
		on f_m_card.card=date_card.card
		order by r
),
--считаем количество дней между последней транзакцией во всей выборке и датой последней покупки для каждого клиента,
-- подтягиваем уже рассчитанные раннее количество покупок и средний чек в одну таблицу
-- обернем последний запрос в подзапрос
percentile_result AS (
    select
    percentile_cont(0.2) within group (order by r) AS per_r_lower,
    percentile_cont(0.66) within group (order by r) AS per_r_higher 
    from 
    rfm_data
),
-- устанавливаем границы для recency/ делаем подзапросом, чтобы далее можно было не использовать группировку
rfm_groups as (
	select card, r, f, m, 
    case 
    	when r > per_r_higher then '3'
    	when r > per_r_lower then '2'
    	else '1'
    end group_r,
    	case 
    		when f > 4 then '1'
    		when f > 2 then '2'
    		else '3'
    	end	group_f,
    		case
	    		when sum (m) over (order by m desc) / sum (m) over () <=0.8 then '1'
	    		when sum (m) over (order by m desc) / sum (m) over () <=0.95 then '2'
	    		else '3'
	    	end group_m
	from
    rfm_data, 
    percentile_result
	order by m desc
),
result as (
	select
	card,
	group_r || group_f || group_m as rfm_result
	from rfm_groups
),
segments as (
    select 
        rfm_result,
        case
            when rfm_result in ('111','112','113','121','122','123') then 'Постоянные клиенты'
            when rfm_result in ('131','132','133') then 'Новые клиенты'
            when rfm_result in ('211','212','213','221','222','223', '231','232','233') then 'Спящие клиенты'
            when rfm_result in ('311','312','313','321','322','323') then 'Уходящие клиенты'
            when rfm_result in ('331','332','333') then 'Клиенты с однокрактной покупкой'
        end "Сегемент"
    from result 
)
select 
    "Сегемент",
    count (*) as "Кол-во клиентов"
from segments
group by "Сегемент"
