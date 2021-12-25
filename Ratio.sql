-------------------
--
-- 同比 环比计算部分 (ORDER 表)
--
-------------------
-- drop table ORDER_PROFIT;
-- drop view ORDER_PROFIT;

select
    order_month,
    temp_db_cal_month.O_YEAR,
    temp_db_cal_month.O_MONTH,
    total_year,
    total_month
into ORDER_PROFIT
FROM
    (
    select
        concat
        (
            cast(O_YEAR as varchar), '-', cast(O_MONTH as varchar)
        ) as order_month,
        sum(O_PROFIT) as total_month,
        O_YEAR,
        O_MONTH
    from ORDERS
    group by
        concat(cast(O_YEAR as varchar), '-', cast(O_MONTH as varchar)),
        O_YEAR,
        O_MONTH
) as temp_db_cal_month,
    (
    select
        O_YEAR,
        sum(O_PROFIT) as total_year
    from ORDERS
    group by O_YEAR
) as temp_db_cal_year
where left(temp_db_cal_month.order_month, 4) = temp_db_cal_year.O_YEAR;

-- 同比 与 环比 计算
select
    db_yoy.order_month as O_ORDER_MONTH,
    db_yoy.O_YEAR,
    db_yoy.O_MONTH,
    db_yoy.total_year as O_TOTAL_YEAR,
    db_yoy.total_month as O_TOTAL_MONTH,
    db_yoy.temp_yoy as O_YOY,
    temp_mom as O_MOM
into ORDER_PROFIT_RATIO
from
    (
    select
        ORDER_PROFIT.order_month,
        ORDER_PROFIT.O_YEAR,
        ORDER_PROFIT.O_MONTH,
        ORDER_PROFIT.total_year,
        ORDER_PROFIT.total_month,
        temp.temp_yoy
    from ORDER_PROFIT
        left join
        (
        select
            d1.order_month,
            d1.O_YEAR,
            d1.O_MONTH,
            round(cast(d1.total_month as float) / cast(ORDER_PROFIT.total_month as float) - 1, 3) as temp_yoy
        from
            (
            select *
            from ORDER_PROFIT
        ) as d1, ORDER_PROFIT
        WHERE
        (
            d1.O_YEAR = ORDER_PROFIT.O_YEAR + 1 and d1.O_MONTH = ORDER_PROFIT.O_MONTH
        )
    )as temp
        on ORDER_PROFIT.order_month = temp.order_month
) as db_yoy
    join
    (
    select
        _temp.order_month,
        _temp.temp_mom
    from ORDER_PROFIT
        left join
        (
        select
            d2.order_month,
            d2.O_YEAR,
            d2.O_MONTH,
            round(cast(d2.total_month as float) / cast(ORDER_PROFIT.total_month as float) - 1, 3) as temp_mom
        from
            (
            select *
            from ORDER_PROFIT
        ) as d2, ORDER_PROFIT
        where
        (
            (d2.O_MONTH = ORDER_PROFIT.O_MONTH + 1 and d2.O_YEAR = ORDER_PROFIT.O_YEAR) or (d2.O_MONTH = 1 and ORDER_PROFIT.O_MONTH = 12 and d2.O_YEAR = ORDER_PROFIT.O_YEAR + 1)
        )
    ) as _temp
        on ORDER_PROFIT.order_month = _temp.order_month
) as temp_2
    on db_yoy.order_month = temp_2.order_month
order by db_yoy.O_YEAR, db_yoy.O_MONTH;

drop table ORDER_PROFIT;
exec sp_rename "ORDER_PROFIT_RATIO", "ORDER_PROFIT";

select *
from ORDER_PROFIT
order by O_YEAR, O_MONTH;