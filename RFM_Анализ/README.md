# Выполнение проекта

Само задание описано в файле ТЗ_проекта

  __1.	Подготовка данных для анализа__


  _1.1 Код. Цель - получить таблицу с данными Recency, Frequency, Monetary_
```
with date_card as (
	select max (datetime::date) as max_date, card
	from bonuscheques b
	where b.card !~ '[A-Za-z]' and CHAR_LENGTH(card)=13
	group by card
	order by max_date desc
),
--выбираем дату самой поздней покупки для каждого пользователя (карты), при этом исключаем карты, которые содержат буквы и обозначаем,
--что номер карты должен содержать ровно 13 символов
f_m_card as (
select card, COUNT(*) as f, AVG(summ) as m
	from bonuscheques b
	where b.card !~ '[A-Za-z]' and CHAR_LENGTH(card)=13
	group by card
)
--для каждой карты считаем количество строк (транзакций) и находим средний чек
select date_card.card,
	first_value (date_card.max_date) over (order by max_date desc) - date_card.max_date as r,
	f_m_card.f,
	round (f_m_card.m,0) as m
from date_card
join f_m_card
on f_m_card.card=date_card.card
order by r
--считаем количество дней между последней транзакцией во всей выборке и датой последней покупки для каждого клиента,
-- подтягиваем уже рассчитанные ранее количество покупок и средний чек в одну таблицу
```
  _1.2 Превью результата_

 <img width="798" height="361" alt="image" src="https://github.com/user-attachments/assets/c9618f85-57a0-4892-ac16-29e8b87d6e21" />



fyi -  r равное 0 означает, что клиент сделал покупку в день последней транзакции в анализируемых данных

Самая давняя покупка относительно последней операции 332 дня назад, что меньше года.
Из анализа никого не исключаем, тк возможно к нам заходят клиенты раз в год, но делают покупку дорогостоящего лекарства, 
курс которого необходимо пропивать как раз раз в год. Необходимо учесть таких людей и также сформировать для них СМС-рассылку.


  __2.	Определение границ сегментов__

  _2.1 Определение границ для Recency_

Один из классических способов определения границ - перцентиль, тк у нас три группы правомерно взять 33 и 66%, 
однако это не до конца прозрачно, возможно такие границы не совсем подходят для имеющихся данных. 
Из результата предыдущего пункта получим следующий график и визуально разделим клиентов на 3 группы.

<img width="994" height="508" alt="image" src="https://github.com/user-attachments/assets/004ebf1d-4791-4d91-a84c-79751a1f1c48" />

Выбор стандартных границ Recency
| Recency (дни)	| %	Recency (дни)	% |
|---|---|
| 48	| 33%	|
| 143	| 66%	|

Выбор границ после визуального представления данных
Recency (дни) | %	Recency (дни)	% |
|---|---|
| 21	| 20% |
| 143	| 66% |

Со стороны здравого смысла - 48 дней с момента последней покупки (33% перцентиль)  достаточно долгий срок. 
Странно будет причислять к первой группе человека, который не посещал сеть наших аптека уже полтора месяца. 

  _2.2	Определение границ для Frequency_

Для определения границ frequency попробуем посмотреть на ящик с усами (на картинке без выбросов):
<img width="689" height="555" alt="image" src="https://github.com/user-attachments/assets/e7dd4e56-aa96-4732-b9db-08085437f5f8" />

 
Медианное количество покупок - 2, т.е большинство клиентов сделали у нас только 2 покупки. Среднее - 4. 
Из графика понимаем, что самая большая группа клиентов покупала у нас 2 - 4 раза. Можем отнести их к группе 2.
К группе 1 отнесем клиентов, которые заходили более 4 раз. 
Группа 3 - клиенты, приобретавшие лекарства в нашей сети только 1 раз. Возможно, это люди, которые зашли к нам “случайно”.

  _2.3	Определение границ для Monetary_

Построим аналогичный график для распределения среднего чека клиентов (на картинке без выбросов)
 
<img width="506" height="538" alt="image" src="https://github.com/user-attachments/assets/3a4665f6-a23e-40ca-9335-ea6711e02a6c" />


Медианные средний чек - 739. Среднее значение среднего чека - 973. 
Для определения границ, будем использовать ABC анализ/правило Парето: 20% усилий дает 80% результата, 
получим следующее распределение:
- Клиенты о средним чеком более 685 - группа 1,
- Те, у кого средний чек 402 - 684 - группа 2,
- Клиенты, приобретающие лекарств у нас менее, чем на 402 руб. единоразово - группа 3
(расчеты приведены ниже, в коде)

  _2.4 Summary границ_

| Группа	| Recency (дней назад) |	Frequency (количество покупок)	| Monetary (средний чек, руб.) |
|---|---|---|---|
| 1	| менее 21	| более 4	| более 685 |
| 2	| 21 - 143 |	2-3 |	402-684 |
| 3	| более 143	| 1	| менее 402 |


__3.	Распределение клиентов по группам__

  _3.1 Код. Цель - получить таблицу с данными распределения по группам_
```
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
-- обернем написанный ранее запрос в подзапрос
percentile_result AS (
   select
   percentile_cont(0.2) within group (order by r) AS per_r_lower,
   percentile_cont(0.66) within group (order by r) AS per_r_higher
   from
   rfm_data
)
-- устанавливаем границы для recency/ делаем подзапросом, чтобы далее можно было не использовать группировку
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
--распределяем по группам значения r, f и m. для m используем правило Парето для этого делим накопленный итог в рамках окна на общий итог
```

  _3.2 Превью результата_

<img width="1260" height="249" alt="image" src="https://github.com/user-attachments/assets/b44690cb-6680-4c96-8aa0-e6eaced2a9c5" />

 


  __4.	Финальная классификация пользователей__

  _4.1 Код. Цель - получить столбец с группой из 3 цифр_
```
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
)
-- обернем написанный ранее запрос в подзапрос
select
card,
group_r || group_f || group_m as rfm_result
from rfm_groups
-- склеиваем финальный результат в 1 строку
```
b.	Превью результата

<img width="694" height="343" alt="image" src="https://github.com/user-attachments/assets/965608a9-1fc1-4ffc-b8c0-6ca3b1d1228d" />


  __5.	Формирование рекомендаций__

- Где группа 111 - клиенты, которые были у нас недавно, покупают часто и на высокий чек
- Группа 333 - возможно, случайные клиенты, который зашли давно, только один раз и купили на низкий чек 

<img width="470" height="338" alt="image" src="https://github.com/user-attachments/assets/5d1742c9-3536-4137-b96b-2122f3cdba12" />

