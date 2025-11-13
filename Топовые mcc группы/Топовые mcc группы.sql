 with sum_trans as(
 select mg.group_name, extract ('month' from p.transaction_date) as month, sum (p.transaction_value) as tr_sum,
 row_number() over (partition by extract ('month' from p.transaction_date) order by sum (p.transaction_value) desc, group_name) as rn
 from purchases p 
 join mcc_codes mc
 ON p.mcc_code_id = mc.mcc_code_id
  AND p.transaction_date BETWEEN valid_from AND valid_to
 join mcc_groups mg 
 on mg.group_id =mc.group_id
 where extract ('year'from p.transaction_date)=2019
 group by extract ('month' from p.transaction_date), mg.group_name, mg.group_id
 ),
 info_with_lead as (
 select group_name, month, tr_sum, rn,
 round(lead (tr_sum) over (partition by month order by tr_sum desc)*1.00,2) as next_tr_sum,
 round(tr_sum-lead (tr_sum) over (partition by month order by tr_sum desc)*1.00,2) as abs_diff,
round((tr_sum-lead (tr_sum) over (partition by month order by tr_sum desc))*1.00/tr_sum,2) as rel_diff
from sum_trans  
),
rn_gen as (
    select 
    null as group_name,
    generate_series(1, 12) as month,
    null as tr_sum, 
    null as abs_diff,
    null as rel_diff
),
cley as (select 
group_name, month, tr_sum, abs_diff, rel_diff
from info_with_lead
where rn=1
)
select 
c.group_name, rg.month, c.tr_sum, c.abs_diff, c.rel_diff
from cley c
right join rn_gen rg
on c.month=rg.month
