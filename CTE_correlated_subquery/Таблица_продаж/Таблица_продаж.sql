WITH dis_apts AS (
    SELECT DISTINCT dr_apt
    FROM sales
),
dis_goods AS (
    SELECT DISTINCT dr_ndrugs
    FROM sales
),
pairs_apt_drud as(SELECT
    a.dr_apt,
    g.dr_ndrugs
FROM dis_apts a
CROSS JOIN dis_goods g
)
select pairs_apt_drud.dr_apt as apt, pairs_apt_drud.dr_ndrugs as drug, round(sum (s.dr_kol::numeric),2) as cnt
from pairs_apt_drud
left join sales s
on pairs_apt_drud.dr_apt=s.dr_apt
	and pairs_apt_drud.dr_ndrugs=s.dr_ndrugs
group by pairs_apt_drud.dr_apt, pairs_apt_drud.dr_ndrugs
