with changes as (
  select client_id, date_change as date_change,  coalesce(address_value, '##########') as address_value, NULL as passport_value
  from client_address_change_log addr
  union
  select client_id, passp.date_change as date_change, NULL as address_value, coalesce(passport_value, '##########') as passport_value
  from client_passport_change_log passp
),
scd as (
select client_id, date_change as valid_from, 
max(passport_value)  as passport_value, 
max(address_value)  as address_value
from changes
 group by client_id, date_change
),
scd_final as(select 
client_id, valid_from,
(LEAD(valid_from,1,to_date('6000.01.01', 'yyyy.mm.dd')) over (PARTITION BY client_id ORDER BY valid_from) - INTERVAL '1 DAY')::date as valid_to,
sum (case when address_value is null then 0 else 1 end)
         over (partition by client_id order by valid_from) as partition_client,
         address_value,
       sum (case when passport_value is null then 0 else 1 end)
         over (partition by client_id order by valid_from) as partition_passport,
         passport_value
from scd
)
select s.client_id,
       cl.client_name,
       s.valid_from,
       s.valid_to,
       case when first_value(s.address_value)
               over (partition by s.client_id, s.partition_client order by valid_from) != '##########'
            then first_value(address_value)
               over (partition by s.client_id, s.partition_client order by valid_from)
       end as address_value,
       case when first_value(passport_value)
               over (partition by s.client_id, s.partition_passport order by valid_from) != '##########'
            then first_value(passport_value)
               over (partition by s.client_id, s.partition_passport order by valid_from)
        end as passport_value
  from scd_final s
  left join merchant.clients cl
    on s.client_id = cl.client_id
