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
--для каждой карты считаем количество строк (транзакций) и находим средний чек
recenc as (
    select 
        card,
        first_value (date_card.max_date) over (order by max_date desc) - date_card.max_date as r
    from date_card
)
select 
    r,
    count (*) as "Кол-во клиентов"
from recenc
group by r
--считаем количество дней между последней транзакцией во всей выборке и датой последней покупки для каждого клиента,
-- подтягиваем уже рассчитанные раннее количество покупок и средний чек в одну таблицу
