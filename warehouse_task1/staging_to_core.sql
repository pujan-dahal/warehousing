----------- DEFINE BUSINESS PROCESS -------------
-- we need to track sales transactions of bike and its accessories
-- solve questions like:
-- what product was sold
-- which customers have bought the product
-- location where the product was sold
-- when product was sold


----------- DEFINE GRANULARITY --------------
SELECT * FROM BIKE_STORE_DB.STAGING.SALES ORDER BY DATE;
-- we can see from the above result that for each day there is multiple number of records i.e. there is record for each order
-- one row is representing one product order
-- so granularity is order wise or transaction wise


----------- IDENTIFY DIMENSIONS -------------
-- date_dim 
    -- attributes: (date_id, date, year, month, day, etc.)
-- customer_dim: 
    -- this is a junk dimension, with attributes: (customer_type_id, age, age_group and gender) attributes,
    -- customer_type_id surrogate key needs to be formed
    -- 4 distinct age groups, 2 distinct genders, 70-100 distinct ages
    -- however there is a 1 to 1 relationship betwee age groups and ages, so max number of possibe rows = 2*100 = 200
-- location_dim
    -- 53 locations across 6 countries
    -- attributes: (location_id, country, stage)
    -- location id is surrogate key
-- product_dim
    -- product_id surrogate key needs to be formed
    -- attributes: (product_id, product, category, sub_category)



----------- IDENTIFY FACTS --------------
-- profit
-- cost
-- revenue
-- order_quantity
-- attributes of fact table: (sales_id, date_fk, customer_type_fk, location_fk, product_fk, order_quantity, unit_cost, unit_price, revenue, cost, profit)
-- sales_id is surrogate key

----------- CREATE DATE DIMENSION TABLE ------------
CREATE OR REPLACE TABLE BIKE_STORE_DB.CORE.DATE_DIM (
  DATE_ID INT NOT NULL, 
  DATE DATE NOT NULL, 
  YEAR SMALLINT NOT NULL, 
  MONTH SMALLINT NOT NULL, 
  MONTH_NAME CHAR(3) NOT NULL, 
  DAY_OF_MON SMALLINT NOT NULL, 
  DAY_OF_WEEK VARCHAR(9) NOT NULL, 
  WEEK_OF_YEAR SMALLINT NOT NULL, 
  DAY_OF_YEAR SMALLINT NOT NULL
) 
AS 
WITH CTE_MY_DATE AS (
  SELECT 
    DATEADD(
      DAY, 
      SEQ4(), 
      '2000-01-01'
    ) AS MY_DATE 
  FROM 
    TABLE(
      GENERATOR(ROWCOUNT => 10000)
    ) -- Number of days after reference date in previous line
    ) 
SELECT
  TO_CHAR(MY_DATE, 'yyyymmdd')::INT AS DATE_ID,
  MY_DATE, 
  YEAR(MY_DATE), 
  MONTH(MY_DATE), 
  MONTHNAME(MY_DATE), 
  DAY(MY_DATE), 
  DAYOFWEEK(MY_DATE), 
  WEEKOFYEAR(MY_DATE), 
  DAYOFYEAR(MY_DATE) 
FROM 
  CTE_MY_DATE;


SELECT * FROM BIKE_STORE_DB.CORE.DATE_DIM;


--------------- CREATE CUSTOMER DIMENSION TABLE ------------------
CREATE OR REPLACE TABLE BIKE_STORE_DB.CORE.CUSTOMER_DIM
(
  CUSTOMER_TYPE_ID INT IDENTITY (1,1) NOT NULL,
  AGE INT NOT NULL,
  AGE_GROUP STRING NOT NULL,
  GENDER CHAR NOT NULL,
  PRIMARY KEY (CUSTOMER_TYPE_ID)
);

--------------- CREATE LOCATION DIMENSION TABLE ------------------
CREATE OR REPLACE TABLE BIKE_STORE_DB.CORE.LOCATION_DIM
(
  LOCATION_ID INT IDENTITY(1,1) NOT NULL,
  COUNTRY STRING NOT NULL,
  STATE STRING NOT NULL,
  PRIMARY KEY (LOCATION_ID)
);

-------------- CREATE PRODUCT DIMENSION TABLE -------------------
CREATE OR REPLACE TABLE BIKE_STORE_DB.CORE.PRODUCT_DIM
(
  PRODUCT_ID INT IDENTITY(1,1) NOT NULL,
  PRODUCT STRING NOT NULL,
  CATEGORY STRING NOT NULL,
  SUB_CATEGORY STRING NOT NULL,
  PRIMARY KEY (PRODUCT_ID)
);


-------------- CREATE SALES FACT TABLE ------------------
CREATE OR REPLACE TABLE BIKE_STORE_DB.CORE.SALES_FACT
(
  SALES_ID INT IDENTITY(1,1) NOT NULL,
  DATE_FK INT NOT NULL,
  CUSTOMER_TYPE_FK INT NOT NULL,
  LOCATION_FK INT NOT NULL,
  PRODUCT_FK INT NOT NULL,
  ORDER_QUANTITY INT NOT NULL,
  UNIT_COST FLOAT NOT NULL,
  UNIT_PRICE FLOAT NOT NULL,
  REVENUE FLOAT NOT NULL,
  COST FLOAT NOT NULL,
  PROFIT FLOAT NOT NULL,
  PRIMARY KEY (SALES_ID)
);

------------- CHECK IF ALL TABLES ARE CREATED ---------------
SELECT * FROM BIKE_STORE_DB.STAGING.SALES;
SELECT * FROM BIKE_STORE_DB.CORE.DATE_DIM;
SELECT * FROM BIKE_STORE_DB.CORE.LOCATION_DIM;
SELECT * FROM BIKE_STORE_DB.CORE.CUSTOMER_DIM;
SELECT * FROM BIKE_STORE_DB.CORE.PRODUCT_DIM;
SELECT * FROM BIKE_STORE_DB.CORE.SALES_FACT;


-------------- ALL THE BELOW STEPS HAVE BEEN AUTOMATED USING STORED PROCEDURE ----------------
-------------- LOADING INITIAL DATA INTO ALL TABLES ----------------
-------------- INSERT INTO CUSTOMER DIMENSION TABLE --------------
-- initial load
INSERT INTO BIKE_STORE_DB.CORE.CUSTOMER_DIM ("AGE", "AGE_GROUP", "GENDER")
SELECT DISTINCT CUSTOMER_AGE, AGE_GROUP, CUSTOMER_GENDER FROM BIKE_STORE_DB.STAGING.SALES ORDER BY CUSTOMER_AGE;


------------- INSERT INTO LOCATION DIMENSION TABLE --------------
-- initial load
INSERT INTO BIKE_STORE_DB.CORE.LOCATION_DIM("COUNTRY", "STATE")
SELECT DISTINCT COUNTRY, STATE FROM BIKE_STORE_DB.STAGING.SALES ORDER BY COUNTRY, STATE;

SELECT * FROM BIKE_STORE_DB.CORE.LOCATION_DIM;


------------- INSERT INTO PRODUCT DIMENSION TABLE ---------------
-- initial load
INSERT INTO BIKE_STORE_DB.CORE.PRODUCT_DIM("PRODUCT", "CATEGORY", "SUB_CATEGORY")
SELECT DISTINCT PRODUCT, PRODUCT_CATEGORY, SUB_CATEGORY FROM BIKE_STORE_DB.STAGING.SALES ORDER BY PRODUCT, PRODUCT_CATEGORY, SUB_CATEGORY;

SELECT * FROM BIKE_STORE_DB.CORE.PRODUCT_DIM;


------------- INSERT INTO FACT TABLE -------------
-- initial load
INSERT INTO BIKE_STORE_DB.CORE.SALES_FACT SF("DATE_FK", "CUSTOMER_TYPE_FK", "LOCATION_FK", "PRODUCT_FK", "ORDER_QUANTITY", "UNIT_COST", "UNIT_PRICE", "REVENUE", "COST", "PROFIT")
SELECT
    EXTRACT (YEAR FROM S.DATE)*10000 + EXTRACT(MONTH FROM S.DATE)*100 + EXTRACT(DAY FROM S.DATE) AS DATE_FK,
    C.CUSTOMER_TYPE_ID AS CUSTOMER_TYPE_FK,
    L.LOCATION_ID AS LOCATION_FK,
    P.PRODUCT_ID AS PRODUCT_FK,
    S.ORDER_QUANTITY,
    S.UNIT_COST,
    S.UNIT_PRICE,
    S.REVENUE,
    S.COST,
    S.PROFIT
    FROM BIKE_STORE_DB.STAGING.SALES S
    LEFT JOIN BIKE_STORE_DB.CORE.CUSTOMER_DIM C
        ON C.AGE = S.CUSTOMER_AGE AND C.GENDER = S.CUSTOMER_GENDER
    LEFT JOIN BIKE_STORE_DB.CORE.LOCATION_DIM L
        ON L.COUNTRY = S.COUNTRY AND L.STATE = S.STATE
    LEFT JOIN BIKE_STORE_DB.CORE.PRODUCT_DIM P
        ON P.PRODUCT = S.PRODUCT AND P.CATEGORY = S.PRODUCT_CATEGORY AND P.SUB_CATEGORY = S.SUB_CATEGORY
    ORDER BY DATE_FK;

SELECT * FROM BIKE_STORE_DB.CORE.SALES_FACT;



---------------- INCREMENTAL LOADING USING THE MERGE INTO SQL COMMAND --------------------
-- LOCATION DIM
MERGE INTO BIKE_STORE_DB.CORE.LOCATION_DIM LT --target table
USING
    (SELECT DISTINCT COUNTRY, STATE FROM BIKE_STORE_DB.STAGING.SALES ORDER BY COUNTRY, STATE) LS -- source table
ON
    LS.COUNTRY = LT.COUNTRY AND LS.STATE = LT.STATE
WHEN NOT MATCHED THEN
    INSERT ("COUNTRY", "STATE") VALUES (LS.COUNTRY, LS.STATE);
    
    
-- CUSTOMER DIM
MERGE INTO BIKE_STORE_DB.CORE.CUSTOMER_DIM CT
USING
    (SELECT DISTINCT CUSTOMER_AGE, AGE_GROUP, CUSTOMER_GENDER FROM BIKE_STORE_DB.STAGING.SALES ORDER BY CUSTOMER_AGE) CS
ON
    CS.CUSTOMER_AGE = CT.AGE AND CS.AGE_GROUP = CT.AGE_GROUP AND CS.CUSTOMER_GENDER = CT.GENDER
WHEN NOT MATCHED THEN
    INSERT ("AGE", "AGE_GROUP", "GENDER") VALUES (CS.CUSTOMER_AGE, CS.AGE_GROUP, CS.CUSTOMER_GENDER);
   
   
-- PRODUCT DIM
MERGE INTO BIKE_STORE_DB.CORE.PRODUCT_DIM PT
USING
    (SELECT DISTINCT PRODUCT, PRODUCT_CATEGORY, SUB_CATEGORY FROM BIKE_STORE_DB.STAGING.SALES ORDER BY PRODUCT, PRODUCT_CATEGORY, SUB_CATEGORY) PS
ON
    PT.PRODUCT = PS.PRODUCT AND PT.CATEGORY = PS.PRODUCT_CATEGORY AND PT.SUB_CATEGORY = PS.SUB_CATEGORY
WHEN NOT MATCHED THEN
    INSERT ("PRODUCT", "CATEGORY", "SUB_CATEGORY") VALUES (PS.PRODUCT, PS.PRODUCT_CATEGORY, PS.SUB_CATEGORY);
    
    
-- SALES FACT TABLE
-- insert new record if new record has date later than previous one already stored in the database, else nothing is done
INSERT INTO BIKE_STORE_DB.CORE.SALES_FACT("DATE_FK", "CUSTOMER_TYPE_FK", "LOCATION_FK", "PRODUCT_FK", "ORDER_QUANTITY", "UNIT_COST", "UNIT_PRICE", "REVENUE", "COST", "PROFIT")
SELECT
    EXTRACT (YEAR FROM S.DATE)*10000 + EXTRACT(MONTH FROM S.DATE)*100 + EXTRACT(DAY FROM S.DATE) AS DATE_FK,
    C.CUSTOMER_TYPE_ID AS CUSTOMER_TYPE_FK,
    L.LOCATION_ID AS LOCATION_FK,
    P.PRODUCT_ID AS PRODUCT_FK,
    S.ORDER_QUANTITY,
    S.UNIT_COST,
    S.UNIT_PRICE,
    S.REVENUE,
    S.COST,
    S.PROFIT
    FROM BIKE_STORE_DB.STAGING.SALES S
    LEFT JOIN BIKE_STORE_DB.CORE.CUSTOMER_DIM C
        ON C.AGE = S.CUSTOMER_AGE AND C.GENDER = S.CUSTOMER_GENDER
    LEFT JOIN BIKE_STORE_DB.CORE.LOCATION_DIM L
        ON L.COUNTRY = S.COUNTRY AND L.STATE = S.STATE
    LEFT JOIN BIKE_STORE_DB.CORE.PRODUCT_DIM P
        ON P.PRODUCT = S.PRODUCT AND P.CATEGORY = S.PRODUCT_CATEGORY AND P.SUB_CATEGORY = S.SUB_CATEGORY
    
    WHERE S.DATE > (SELECT DATE 
                        FROM (SELECT MAX(DATE_FK) AS MAX_DATE_FK FROM BIKE_STORE_DB.CORE.SALES_FACT) T1 
                     INNER JOIN BIKE_STORE_DB.CORE.DATE_DIM T2 
                     ON T1.MAX_DATE_FK = T2.DATE_ID) -- selecting max date by joining sales fact with date dim table
    ORDER BY DATE_FK;
