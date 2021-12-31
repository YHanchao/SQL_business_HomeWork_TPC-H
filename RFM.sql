-------------------------------------
--
-- RFM 数据处理
--
--     重生之谁是大客户
--
--     后续用 Python 弄个 k-means 聚类
--
-------------------------------------

SELECT
    CUSTOMER.C_CUSTKEY,
    DATEDIFF
    (
        DAY,
        '1998-01-01',
        (
            SELECT
                TOP 1
                TEMP.O_ORDERDATE
            FROM
            (
                SELECT *
                    FROM ORDERS
                    WHERE ORDERS.O_CUSTKEY = CUSTOMER.C_CUSTKEY
            ) TEMP
            ORDER BY O_YEAR DESC, O_MONTH DESC, O_DAY DESC
        )
    ) AS RECENCY
    ,
    (
        SELECT
            COUNT(TEMP.O_CUSTKEY)
        FROM
        (
            SELECT *
            FROM ORDERS
            WHERE ORDERS.O_CUSTKEY = CUSTOMER.C_CUSTKEY
        ) TEMP
        WHERE TEMP.O_YEAR = 1998
    ) AS FREQUECY,
    (
        SELECT
            SUM (TEMP.O_TOTALPRICE)
        FROM
        (
            SELECT *
            FROM ORDERS
            WHERE ORDERS.O_CUSTKEY = CUSTOMER.C_CUSTKEY
        ) TEMP
        WHERE TEMP.O_YEAR = 1998
    ) AS MONETARY
INTO RFM
FROM CUSTOMER;

DELETE FROM RFM WHERE RECENCY IS NULL;
UPDATE RFM SET MONETARY = 0 WHERE MONETARY IS NULL;

--
-- USING PYTHON
--
--     TODO: K-MEANS
--

CREATE TABLE RFM_TEMP
(
    C_CUSTKEY INTEGER PRIMARY KEY,
    RECENCY_STD DECIMAL,
    FREQUENCY_STD FLOAT,
    MONETARY_STD DECIMAL,
    C_TYPE INTEGER
);

BULK INSERT RFM_TEMP
FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\RFM_TEMP.csv'
with
(
    fieldterminator=',',
    firstrow=2,
    rowterminator='\n'
);

ALTER TABLE RFM ADD CUS_TYPE INTEGER;
UPDATE RFM SET CUS_TYPE = 
(
    SELECT RFM_TEMP.C_TYPE FROM RFM_TEMP
    WHERE RFM_TEMP.C_CUSTKEY = RFM.C_CUSTKEY
);
drop table rfm_temp;

UPDATE RFM SET CUS_TYPE = -1 WHERE CUS_TYPE IS NULL;

-- 将结果合并到 CUSTOMER 表中
SELECT
    CUSTOMER.C_CUSTKEY,
    RFM.RECENCY,
    RFM.FREQUECY,
    RFM.MONETARY,
    RFM.CUS_TYPE
INTO RFM_TEMP
FROM CUSTOMER
LEFT JOIN RFM
ON RFM.C_CUSTKEY = CUSTOMER.C_CUSTKEY;

DROP TABLE RFM
EXEC sp_rename 'RFM_TEMP', 'RFM'

UPDATE RFM SET CUS_TYPE = -2 WHERE RECENCY IS NULL;

ALTER TABLE RFM ADD TYPE_NAME VARCHAR(10);
UPDATE RFM SET TYPE_NAME = 'Keep' WHERE CUS_TYPE = 0;
UPDATE RFM SET TYPE_NAME = 'Progress' WHERE CUS_TYPE = 1;
UPDATE RFM SET TYPE_NAME = 'High-value' WHERE CUS_TYPE = 2;
UPDATE RFM SET TYPE_NAME = 'Potential' WHERE CUS_TYPE = 3;
UPDATE RFM SET TYPE_NAME = 'Potential' WHERE CUS_TYPE = -1;
UPDATE RFM SET TYPE_NAME = 'Unbuy' WHERE CUS_TYPE = -2;