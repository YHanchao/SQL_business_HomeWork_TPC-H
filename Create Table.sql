-------------------------------
-- 
--          建表部分
--
-------------------------------

-- 新建表

CREATE TABLE PART
(
    P_PARTKEY integer PRIMARY KEY,
    P_NAME varchar(55),
    P_MFGR char(25),
    P_BRAND char(10),
    P_TYPE varchar(25),
    P_SIZE integer,
    P_CONTAINER char(10),
    P_RETAILPRICE decimal,
    P_COMMENT varchar(23)
);

CREATE TABLE SUPPLIER
(
    S_SUPPKEY integer PRIMARY KEY,
    S_NAME char(25),
    S_ADDRESS varchar(40),
    S_NATIONKEY integer,
    S_PHONE char(15),
    S_ACCTBAL decimal,
    S_COMMENT varchar(101)
);


CREATE TABLE PARTSUPP
(
    PS_PARTKEY integer,
    PS_SUPPKEY integer,
    PS_AVAILQTY integer,
    PS_SUPPLYCOST Decimal,
    PS_COMMENT varchar(199),
    -- PRIMARY KEY(PS_PARTKEY, PS_SUPPKEY)
);


CREATE TABLE CUSTOMER
(
    C_CUSTKEY integer PRIMARY KEY,
    C_NAME varchar(25),
    C_ADDRESS varchar(40),
    C_NATIONKEY integer,
    C_PHONE char(15),
    C_ACCTBAL Decimal,
    C_MKTSEGMENT char(10),
    C_COMMENT varchar(117)
);


CREATE TABLE ORDERS
(
    O_ORDERKEY integer PRIMARY KEY,
    O_CUSTKEY integer,
    O_ORDERSTATUS char(1),
    O_TOTALPRICE Decimal,
    O_ORDERDATE Date,
    O_ORDERPRIORITY char(15),
    O_CLERK char(15),
    O_SHIPPRIORITY Integer,
    O_COMMENT varchar(79)
);


CREATE TABLE LINEITEM
(
    L_ORDERKEY integer,
    L_PARTKEY integer,
    L_SUPPKEY integer,
    L_LINENUMBER integer,
    L_QUANTITY decimal,
    L_EXTENDEDPRICE decimal,
    L_DISCOUNT decimal,
    L_TAX decimal,
    L_RETURNFLAG char(1),
    L_LINESTATUS char(1),
    L_SHIPDATE date,
    L_COMMITDATE date,
    L_RECEIPTDATE date,
    L_SHIPINSTRUCT char(25),
    L_SHIPMODE char(10),
    L_COMMENT varchar(44),
    PRIMARY KEY(L_ORDERKEY, L_LINENUMBER)
);


CREATE TABLE NATION
(
    N_NATIONKEY integer PRIMARY KEY,
    N_NAME char(25),
    N_REGIONKEY integer,
    N_COMMENT varchar(152)
);


CREATE TABLE REGION
(
    R_REGIONKEY integer PRIMARY KEY,
    R_NAME char(25),
    R_COMMENT varchar(152)
);

-- 导入数据

BULK INSERT PART FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\part.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT SUPPLIER FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\supplier.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT PARTSUPP FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\partsupp.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT CUSTOMER FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\customer.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT ORDERS FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\orders.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT LINEITEM FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\lineitem.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT NATION FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\nation.tbl' with (fieldterminator='|', rowterminator='\n');
BULK INSERT REGION FROM 'D:\Programs\Term 3 - SQL Business\Homework 03 - Final Work\Data\region.tbl' with (fieldterminator='|', rowterminator='\n');

-- 针对 PARTSUPP 和 LINEITEM 修改约束

alter table PARTSUPP add PS_MYKEY varchar(11);

select PS_PARTKEY, PS_SUPPKEY, concat(cast(PARTSUPP.PS_PARTKEY as varchar), ',',  cast(PARTSUPP.PS_SUPPKEY as varchar)) as PS_MYKEY
into PARTSUPP_TEMP
from PARTSUPP;

update PARTSUPP set PARTSUPP.PS_MYKEY = PARTSUPP_TEMP.PS_MYKEY
from PARTSUPP, PARTSUPP_TEMP
WHERE PARTSUPP.PS_PARTKEY = PARTSUPP_TEMP.PS_PARTKEY and PARTSUPP.PS_SUPPKEY = PARTSUPP_TEMP.PS_SUPPKEY;

drop table PARTSUPP_TEMP

alter table LINEITEM add L_MYKEY varchar(11);

select L_PARTKEY, L_SUPPKEY, concat(cast(LINEITEM.L_PARTKEY as varchar), ',',  cast(LINEITEM.L_SUPPKEY as varchar)) as L_MYKEY
into LINEITEM_TEMP
from LINEITEM;

update LINEITEM set LINEITEM.L_MYKEY = LINEITEM_TEMP.L_MYKEY
from LINEITEM, LINEITEM_TEMP
WHERE LINEITEM.L_PARTKEY = LINEITEM_TEMP.L_PARTKEY and LINEITEM.L_SUPPKEY = LINEITEM_TEMP.L_SUPPKEY;

drop table LINEITEM_TEMP

alter table PARTSUPP alter column PS_MYKEY varchar(11) not null;

alter table PARTSUPP add PRIMARY key (PS_MYKEY);
alter table LINEITEM add foreign key (L_MYKEY) references PARTSUPP (PS_MYKEY);


-- 创建约束

ALTER TABLE PARTSUPP ADD FOREIGN KEY (PS_PARTKEY) REFERENCES PART (P_PARTKEY);
ALTER TABLE PARTSUPP ADD FOREIGN KEY (PS_SUPPKEY) REFERENCES SUPPLIER (S_SUPPKEY);
ALTER TABLE CUSTOMER ADD FOREIGN KEY (C_NATIONKEY) REFERENCES NATION(N_NATIONKEY);
ALTER TABLE SUPPLIER ADD FOREIGN KEY (S_NATIONKEY) REFERENCES NATION(N_NATIONKEY);
ALTER TABLE ORDERS ADD FOREIGN KEY (O_CUSTKEY) REFERENCES CUSTOMER(C_CUSTKEY);
ALTER TABLE NATION ADD FOREIGN KEY (N_REGIONKEY) REFERENCES REGION(R_REGIONKEY);
ALTER TABLE LINEITEM ADD FOREIGN KEY (L_ORDERKEY) REFERENCES ORDERS(O_ORDERKEY);

-- 计算 LINEITEM 上的利润

alter table LINEITEM add L_COST integer; -- 成本

-- update LINEITEM set L_COST = 
