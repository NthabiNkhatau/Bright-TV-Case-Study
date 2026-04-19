
--- Viewing what is in the datasets: first 100 rows of the user_profiles and viewrship table
SELECT * 
FROM `workspace`.`default`.`user_profiles` 
LIMIT 100;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- --

SELECT * 
FROM `workspace`.`default`.`viewership` 
LIMIT 100;

--- Joining the two tables, using full outer join

SELECT 
      u.*,
      v.*
FROM  `workspace`.`default`.`user_profiles` AS u
FULL OUTER JOIN `workspace`.`default`.`viewership` AS v
ON u.UserID = v.UserID0;


--The conversion of time from UCT to SA time 

SELECT *,
    from_utc_timestamp(TO_TIMESTAMP(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS SA_timestamp
FROM `workspace`.`default`.`viewership`;

--------------------------------------------------------------------
BASIC PROFILE CHECKS
----------------------------------------------------------------------
 
---- Distinct gender values
SELECT DISTINCT Gender
FROM `workspace`.`default`.`user_profiles`;
 
---- Distinct race values
SELECT DISTINCT Race
FROM `workspace`.`default`.`user_profiles`;
 
---- Distinct provinces
SELECT DISTINCT Province
FROM `workspace`.`default`.`user_profiles`;
 
---- Age range in the profile table
SELECT
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM `workspace`.`default`.`user_profiles`;

-----Creating Age Group brackets 
SELECT Age,
    CASE 
        WHEN Age < 18 THEN 'Minor'
        WHEN Age BETWEEN 18 AND 25 THEN 'Youth'
        WHEN Age BETWEEN 26 AND 35 THEN 'Middle Age'
        WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
        ELSE 'Elder'
    END AS Age_group
FROM `workspace`.`default`.`user_profiles`;

---------------------------------------------------------------------- 
BASIC VIEWERSHIP CHECKS
----------------------------------------------------------------------
 
---- Distinct channels / content watched
SELECT DISTINCT Channel2
FROM `workspace`.`default`.`viewership`;
 
---- Check date range of sessions
SELECT
    MIN(RecordDate2) AS Start_Date_UTC,
    MAX(RecordDate2) AS End_Date_UTC
FROM `workspace`.`default`.`viewership`;
 
---- Check number of records and unique users in the viewership data
SELECT
    COUNT(*) AS Number_Of_Sessions,
    COUNT(DISTINCT UserID0) AS Distinct_UserID_Field,
    COUNT(DISTINCT userid4) AS Distinct_userid_Field
FROM `workspace`.`default`.`viewership`;
 
----------------------------------------------------------------------
---- 5) CHECK FOR NULLS / BLANKS
----------------------------------------------------------------------
 
---- Nulls in user profile table
SELECT *
FROM `workspace`.`default`.`user_profiles`
WHERE UserID IS NULL
   OR Name IS NULL
   OR Surname IS NULL
   OR Email IS NULL
   OR Gender IS NULL
   OR Race IS NULL
   OR Age IS NULL
   OR Province IS NULL;
 
---- Nulls in viewership table
SELECT *
FROM `workspace`.`default`.`viewership`
WHERE UserID0 IS NULL
   OR userid4 IS NULL
   OR Channel2 IS NULL
   OR RecordDate2 IS NULL
   OR `Duration 2` IS NULL;

---Best Performing Content
SELECT 
    v.Channel2,
    COUNT(*) AS Total_views
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_profiles` u
    ON u.UserID = v.UserID0
GROUP BY v.Channel2
ORDER BY Total_views DESC
LIMIT 5;

-----------------------------------------------
---THE CONSOLIDATED QUERY/ CODE
--------------------------------------------------
   
SELECT 
    u.UserID,
    u.Age,
    CASE 
        WHEN u.Age < 18 THEN 'Minor'
        WHEN u.Age BETWEEN 18 AND 25 THEN 'Youth'
        WHEN u.Age BETWEEN 26 AND 35 THEN 'Middle Age'
        WHEN u.Age BETWEEN 36 AND 50 THEN 'Adult'
        ELSE 'Elder'
    END AS Age_group,
    u.Gender,
    u.Race,
    u.Province,
    v.Channel2 AS Channel,
    v.RecordDate2,

    TO_DATE(
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
            'Africa/Johannesburg'
        )
    ) AS Record_Date,

    DATE_FORMAT(
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
            'Africa/Johannesburg'
        ),
        'HH:mm:ss'
    ) AS Record_Time,

    DATE_FORMAT(
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
            'Africa/Johannesburg'
        ),
        'EEEE'
    ) AS Day_Name,

    DATE_FORMAT(
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
            'Africa/Johannesburg'
        ),
        'MMMM'
    ) AS Month_Name,

    CASE
        WHEN DATE_FORMAT(
            FROM_UTC_TIMESTAMP(
                TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
                'Africa/Johannesburg'
            ),
            'EEEE'
        ) IN ('Saturday','Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Classification,

    HOUR(
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),
            'Africa/Johannesburg'
        )
    ) AS Hour_SA,

    CASE
        WHEN HOUR(FROM_UTC_TIMESTAMP(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg')) BETWEEN 6 AND 9 THEN 'Early Morning'
        WHEN HOUR(FROM_UTC_TIMESTAMP(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg')) BETWEEN 10 AND 12 THEN 'Late Morning'
        WHEN HOUR(FROM_UTC_TIMESTAMP(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg')) BETWEEN 13 AND 15 THEN 'Early Afternoon'
        WHEN HOUR(FROM_UTC_TIMESTAMP(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg')) BETWEEN 16 AND 18 THEN 'Late Afternoon'
        WHEN HOUR(FROM_UTC_TIMESTAMP(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'),'Africa/Johannesburg')) BETWEEN 19 AND 22 THEN 'Evening'
        ELSE 'Late Night'
    END AS Time_Bucket,

    v.`Duration 2` AS Duration_Time,

    (
        (HOUR(v.`Duration 2`) * 3600) +
        (MINUTE(v.`Duration 2`) * 60) +
        SECOND(v.`Duration 2`)
    ) AS Duration_Seconds,

    ROUND(
        (
            (HOUR(v.`Duration 2`) * 3600) +
            (MINUTE(v.`Duration 2`) * 60) +
            SECOND(v.`Duration 2`)
        ) / 60, 2
    ) AS Duration_Minutes

FROM `workspace`.`default`.`user_profiles` u
JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.UserID0;
