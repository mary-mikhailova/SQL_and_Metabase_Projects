 with ranked_transactions as (SELECT 
 g.group_id,
  g.group_name as group_name,
  p.transaction_value,
  EXTRACT('year' FROM p.transaction_date) AS year,
  ROW_NUMBER() OVER (PARTITION BY g.group_name, EXTRACT('year' FROM p.transaction_date) ORDER BY p.transaction_value DESC) AS rn 
FROM 
  purchases p
JOIN 
  mcc_codes mc ON p.mcc_code_id = mc.mcc_code_id
  AND p.transaction_date BETWEEN valid_from AND valid_to
JOIN 
  mcc_groups g ON mc.group_id = g.group_id
WHERE 
  EXTRACT('year' FROM p.transaction_date) BETWEEN 2019 AND 2020
 ),
rn_gen as (
    select group_id,
           group_name,
           year,
           rn
    from
    (
        select distinct group_id, group_name
        from mcc_groups
    ) g
    cross join
    (
    select generate_series(2019, 2020) as year
    ) y
    cross join
    (
    select generate_series(1, 3) as rn
    ) r
   )
select rg.group_name, rg.year, rg.rn, round(rt.transaction_value,2) as transaction_value
from ranked_transactions rt
right join rn_gen rg
on rt.group_id = rg.group_id
and rt.rn = rg.rn
 and rt.year = rg.year
 order by group_name, rn, rg.year
