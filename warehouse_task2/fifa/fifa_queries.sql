--------------- WORKING WITH JSON DATA ------------------
--------------- CREATE THE DATABASE, WAREHOUSE AND SCHEMA -----------------
CREATE DATABASE FIFA_WORLD_CUP;
CREATE SCHEMA FIFA_WORLD_CUP.GROUP_STAGE;
CREATE STAGE FIFA_WORLD_CUP.GROUP_STAGE.RAW_STAGE;
CREATE WAREHOUSE FIFA_WAREHOUSE;


-------------- UPLOAD JSON TO RAW STAGE USING SNOWSQL CLIENT -------------------
-- PUT file://<path_to_file>/fifa/fifawc22_qatar_group_stage.json @RAW_STAGE;

LIST @RAW_STAGE;

-------------- CREATE TABLE TO STORE JSON -----------------
CREATE OR REPLACE TABLE GROUPS
(
  JSON_DATA VARIANT
);

-------------- LOAD RAW DATA INTO UNFORMATTED TABLE ---------------
COPY INTO GROUPS
FROM @RAW_STAGE/fifawc22_qatar_group_stage.json.gz
FILE_FORMAT = (TYPE = JSON);

-------------- CHECK LOADED DATA ----------------
SELECT * FROM FIFA_WORLD_CUP.GROUP_STAGE.GROUPS;

-------------- QUERY TABLE ---------------
-- INITIALLY THE JSON DATA CONSISTS OF AN ARRAY OF OBJECTS (AN OBJECT FOR EACH GROUP)
SELECT
VALUE
FROM GROUPS,
LATERAL FLATTEN(INPUT => JSON_DATA);

-------------- CREATE TABLE IN WHICH ONE RECORD REPRESENTS ONE GROUP, SO THAT WE CAN FLATTEN FURTHER ----------------
CREATE OR REPLACE TABLE GROUPS_FLAT AS
SELECT
VALUE AS GROUP_DATA
FROM GROUPS,
LATERAL FLATTEN(INPUT => JSON_DATA);


SELECT * FROM GROUPS_FLAT;


------------- FOR EACH ROW OF GROUP DATA FLATTEN IT -----------------
SELECT 
*
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA);

------------- GET ALL RANKS -------------
SELECT
PATH,
VALUE:RANK_1:TEAM:TEAM_NAME_ABBR::VARCHAR RANK_1,
VALUE:RANK_2:TEAM:TEAM_NAME_ABBR::VARCHAR RANK_2,
VALUE:RANK_3:TEAM:TEAM_NAME_ABBR::VARCHAR RANK_3,
VALUE:RANK_4:TEAM:TEAM_NAME_ABBR::VARCHAR RANK_4
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA);

-------------- RECURSIVE FLATTEN --------------
SELECT *
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA, RECURSIVE => TRUE);


-------------- CREATE SEPARATE TABLES FOR ALL GROUPS ------------
-------------- GET GROUP A TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_A
AS
SELECT
'GROUP_A' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_A, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;


-------------- GET GROUP B TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_B
AS
SELECT
'GROUP_B' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_B, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;


-------------- GET GROUP C TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_C
AS
SELECT
'GROUP_C' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_C, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;


-------------- GET GROUP D TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_D
AS
SELECT
'GROUP_D' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_D, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;

-------------- GET GROUP E TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_E
AS
SELECT
'GROUP_E' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_E, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;

-------------- GET GROUP F TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_F
AS
SELECT
'GROUP_F' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_F, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;

-------------- GET GROUP G TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_G
AS
SELECT
'GROUP_G' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_G, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;

-------------- GET GROUP H TEAMS PERFORMANCE ---------------
CREATE OR REPLACE TABLE GROUP_H
AS
SELECT
'GROUP_H' GROUP_NAME,
VALUE:TEAM:TEAM_NAME_ABBR::VARCHAR TEAM_NAME,
VALUE:PERFORMANCE:GP::INT PLAYED,
VALUE:PERFORMANCE:W::INT WON,
VALUE:PERFORMANCE:L::INT LOST,
VALUE:PERFORMANCE:D::INT DRAW,
VALUE:PERFORMANCE:GC::INT GOAL_CONCEDED,
VALUE:PERFORMANCE:GS::INT GOAL_SCORED,
VALUE:PERFORMANCE:GD::INT GOAL_DIFF,
VALUE:PERFORMANCE:Pts::INT POINTS,
ROW_NUMBER() OVER(ORDER BY POINTS DESC, GOAL_DIFF DESC) RANK
FROM GROUPS_FLAT,
LATERAL FLATTEN(INPUT => GROUP_DATA:GROUP_H, RECURSIVE => TRUE)
WHERE TEAM_NAME IS NOT NULL;


------------- CHECK ALL TABLES ------------------
SELECT * FROM GROUP_A;
SELECT * FROM GROUP_B;
SELECT * FROM GROUP_C;
SELECT * FROM GROUP_D;
SELECT * FROM GROUP_E;
SELECT * FROM GROUP_F;
SELECT * FROM GROUP_G;
SELECT * FROM GROUP_H;