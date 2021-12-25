-- 计算利润

-- 对 lineitem 表计算利润

select PS_MYKEY from PARTSUPP
alter table lineitem add L_COST integer;

update lineitem set L_COST = LINEITEM.L_QUANTITY * PARTSUPP.PS_SUPPLYCOST
from lineitem, partsupp
where LINEITEM.L_MYKEY = PARTSUPP.PS_MYKEY

alter table lineitem add L_PROFIT integer;
update lineitem set L_PROFIT = L_EXTENDEDPRICE - L_COST;

-- 对 orders 表汇总利润

alter table orders add O_PRICE integer;
alter table orders add O_PROFIT integer;

update orders set O_PRICE = TEMP.O_PRICE from
(
    select ORDERS.O_ORDERKEY, sum(LINEITEM.L_QUANTITY * PARTSUPP.PS_SUPPLYCOST) as O_PRICE
    from lineitem, partsupp, ORDERS
    where ORDERS.O_ORDERKEY = LINEITEM.L_ORDERKEY AND PARTSUPP.PS_PARTKEY = LINEITEM.L_PARTKEY AND PARTSUPP.PS_SUPPKEY = LINEITEM.L_SUPPKEY
    group by ORDERS.O_ORDERKEY
) TEMP, ORDERS
where TEMP.O_ORDERKEY = ORDERS.O_ORDERKEY;
update orders set O_PROFIT = O_TOTALPRICE - O_PRICE;
