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
)
select 
    f, 
    count (*)
from f_m_card
group by f
having f <= 60
