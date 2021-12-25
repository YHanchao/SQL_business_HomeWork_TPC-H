--------------------------
--
-- 用户购买情况分析
--
--     重生之我是大客户（
--
--------------------------

SELECT
    TEMP.C_NAME,
    TEMP.C_CUSTKEY,
    TEMP.C_NATIONKEY,
    TEMP.YEAR,
    BMONTH.MONTH,
    TEMP.B_YEAR,
    BMONTH.B_MONTH
INTO
    CUS_PROFIT
FROM
(
    SELECT
        CUSTOMER.C_NAME,
        CUSTOMER.C_CUSTKEY,
        CUSTOMER.C_NATIONKEY,
        BUY.YEAR,
        BUY.B_YEAR
        -- BUY.B_RATIO
    FROM CUSTOMER
    RIGHT JOIN
    (
        SELECT
            O_CUSTKEY,
            O_YEAR AS YEAR,
            SUM(O_PROFIT) AS B_YEAR
        FROM
            ORDERS
        GROUP BY O_CUSTKEY, ORDERS.O_YEAR
        --ORDER BY O_CUSTKEY, ORDERS.O_YEAR
    ) AS BUY
    ON BUY.O_CUSTKEY = CUSTOMER.C_CUSTKEY
) AS TEMP
JOIN
(
    SELECT
        CUSTOMER.C_NAME,
        CUSTOMER.C_CUSTKEY,
        CUSTOMER.C_NATIONKEY,
        _BUY.YEAR,
        _BUY.MONTH,
        _BUY.B_MONTH
    FROM CUSTOMER
    RIGHT JOIN
    (
        SELECT
            O_CUSTKEY,
            O_YEAR AS YEAR,
            O_MONTH AS MONTH,
            SUM(O_PROFIT) AS B_MONTH
        FROM
            ORDERS
        GROUP BY O_CUSTKEY, ORDERS.O_YEAR, ORDERS.O_MONTH
    ) AS _BUY
    ON _BUY.O_CUSTKEY = CUSTOMER.C_CUSTKEY
    --ORDER BY _BUY.O_CUSTKEY, _BUY.YEAR, _BUY.MONTH
) AS BMONTH
ON BMONTH.C_CUSTKEY = TEMP.C_CUSTKEY AND BMONTH.YEAR = TEMP.YEAR
ORDER BY TEMP.C_CUSTKEY, TEMP.YEAR, BMONTH.MONTH;