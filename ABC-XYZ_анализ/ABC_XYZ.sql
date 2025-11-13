with apr as (
select 
	dr_ndrugs, 
	sum(dr_kol) as amount,
	sum(dr_kol*dr_croz-dr_sdisc) as revenue,
	sum(dr_kol*(dr_croz-dr_czak)-dr_sdisc) as profit
from sales
group by dr_ndrugs
),
xyz_prep as(
	select 
		dr_ndrugs as product, 
		sum (dr_kol) as sales, 
		to_char(dr_dat, 'YYYY-WW') AS week
from sales
group by dr_ndrugs, week
),
xyz_result as(
	select 
	product, 
	case 
		when stddev_samp(sales) / avg(sales) * 100 > 25 then 'Z'
		when stddev_samp(sales) / avg(sales) * 100 > 10 then 'Y'
		else 'X'
	end xyz_sales
from xyz_prep
GROUP BY product
having count(distinct week) >= 4
)
select dr_ndrugs as product,
	case 
		when sum (amount) over (order by amount desc)/ sum (amount) over () <=0.8 then 'A'
		when sum (amount) over (order by amount desc)/ sum (amount) over () <=0.95 then 'B'
		else 'C'
	end amount_abc,
	case 
		when sum (profit) over (order by profit desc)/ sum (profit) over () <=0.8 then 'A'
		when sum (profit) over (order by profit desc)/ sum (profit) over () <=0.95 then 'B'
		else 'C'
	end profit_abc,
	case 
		when sum (revenue) over (order by revenue desc)/ sum (revenue) over () <=0.8 then 'A'
		when sum (revenue) over (order by revenue desc)/ sum (revenue) over () <=0.95 then 'B'
		else 'C'
	end revenue_abc,
	xyz_sales
from apr
left join xyz_result
	on xyz_result.product=apr.dr_ndrugs
order by product 
