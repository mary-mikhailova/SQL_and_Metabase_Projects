/*Воронка "Сделал попытку решить задачу - Решил задачу успешно - Пополнил кошелек"*/

WITH
  tries AS (
    SELECT
      user_id
    FROM
      coderun cr
    WHERE
      TRUE [[and created_at between {{date1}} and {{date2}}]]
    UNION
    SELECT
      user_id
    FROM
      codesubmit cs
    WHERE
      TRUE [[and created_at between {{date1}} and {{date2}}]]
  )
SELECT
  'Попытка решения' AS metric,
  count(*) AS "Количество"
FROM
  tries
UNION ALL
SELECT
  'Успешное решение' AS metric,
  count(
    DISTINCT CASE
      WHEN is_false = 0 THEN user_id
    END
  ) AS "Количество"
FROM
  codesubmit
WHERE
  TRUE [[and created_at between {{date1}} and {{date2}}]]
UNION ALL
SELECT
  'Пополнение кошелька' AS metric,
  count(DISTINCT user_id) AS "Количество"
FROM
  TRANSACTION
WHERE
  TRUE
  AND type_id = 2 [[and created_at between {{date1}} and {{date2}}]]


/*Распределение первых и повторных покупок*/
  
WITH
  cnt AS (
    SELECT
      TRANSACTION.user_id,
      count(*) AS amout_transactions
    FROM
      TRANSACTION
      JOIN transactiontype ON transactiontype.type = TRANSACTION.type_id
    WHERE
      TRUE
      AND TRANSACTION.type_id = 1
      OR TRANSACTION.type_id BETWEEN 23 AND 28
      AND {{created_at}}
    GROUP BY
      TRANSACTION.user_id
    ORDER BY
      count(*)
  )
SELECT
  'Повторные покупки' AS "Кол-во покупок",
  count(
    CASE
      WHEN amout_transactions > 1 THEN 1
    END
  ) AS VALUE
FROM
  cnt
UNION ALL
SELECT
  'Первая покупка' AS "Кол-во покупок",
  count(
    CASE
      WHEN amout_transactions = 1 THEN 1
    END
  ) AS VALUE
FROM
  cnt

/*Rolling retention*/
  
WITH
  days AS (
    SELECT
      to_char(users.date_joined, 'YYYY-MM') AS cogort,
      userentry.user_id AS id,
      extract(
        days
        FROM
          userentry.entry_at - users.date_joined
      ) AS diff_days
    FROM
      users
      LEFT JOIN userentry ON userentry.user_id = users.id
    WHERE
      TRUE
      AND userentry.entry_at::date - users.date_joined::date >= 0 [[and users.date_joined between {{date_joined1}} and {{date_joined2}}]]
  )
SELECT
  cogort,
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "0(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 1 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "1(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 3 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "3(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 7 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "7(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 14 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "14(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 30 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "30(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 60 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "60(%)",
  round(
    count(
      DISTINCT CASE
        WHEN diff_days >= 90 THEN id
      END
    ) * 100.0 / count(
      DISTINCT CASE
        WHEN diff_days >= 0 THEN id
      END
    ),
    2
  ) AS "90(%)"
FROM
  days
GROUP BY
  cogort
ORDER BY
  cogort
