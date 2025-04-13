# World Life Expectancy Project (Data Cleaning) 

SELECT * 
FROM world_life_expectancy
;

#Check for Duplicates 
Select Country, Year, CONCAT(Country, Year), Count(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
Having Count(CONCAT(Country, Year))>1
;


Select * 
From(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(Partition by CONCAT(Country, Year) ORDER BY CONCAT(Country, YEAR)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
Where Row_Num > 1
;
 
#Remove Identified Duplicates 
 DELETE FROM world_life_expectancy
 Where 
	ROW_ID IN (
    Select Row_ID 
From(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(Partition by CONCAT(Country, Year) ORDER BY CONCAT(Country, YEAR)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
Where Row_Num > 1
)
;
#Checking for Blanks/Nulls

SELECT *
FROM world_life_expectancy
Where Status = ''
; 

SELECT DISTINCT(Status)
FROM world_life_expectancy
Where Status <> ''
; 

SELECT DISTINCT(Country) 
FROM world_life_expectancy
Where Status = 'Developing'
;

#Creating an Inner join on itself to populate blanks 

UPDATE world_life_expectancy
SET STATUS = 'Developing' 
Where Country IN (SELECT DISTINCT(Country) 
				FROM world_life_expectancy
				Where Status = 'Developing');
   
#Populate blanks for where there should be listed as 'developed' or 'developing'
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country 
SET t1.Status = 'Developing'
Where t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country 
SET t1.Status = 'Developed'
Where t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

#To fill in the blanks, we will take the average of the value for the year above and below for the country. 
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.YEAR, t1.`Life expectancy`,
t2.Country, t2.YEAR, t2.`Life expectancy`,
t3.Country, t3.YEAR, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
        AND t1.YEAR = t2.YEAR - 1
JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
        AND t1.YEAR = t3.YEAR + 1
WHERE t1.`Life expectancy` = '' 
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
        AND t1.YEAR = t2.YEAR - 1
JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
        AND t1.YEAR = t3.YEAR + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;


# World Life Expectancy Project EDA 


#
SELECT Country,
 MIN(`Life expectancy`),
 MAX(`Life expectancy`),
 ROUND( MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years 
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years 
; 

SELECT YEAR, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0 
AND `Life expectancy` <> 0
GROUP BY YEAR
ORDER BY YEAR
;

SELECT *
FROM world_life_expectancy
;

SELECT Country, round(MIN(`under-five deaths`),1) AS MIN_INFANT_DEATHS,
round(AVG(`under-five deaths`),1) AS AVG_INFANT_DEATHS, 
round(MAX(`under-five deaths`),1) AS MAX_INFANT_DEATHS
FROM world_life_expectancy
GROUP BY Country 
HAVING MIN(`under-five deaths`) <> 0 
AND MAX(`under-five deaths`) <> 0
Order By AVG_INFANT_DEATHS DESC
;

SELECT Country, 
ROUND(AVG(`Life Expectancy`),1) AS Life_Exp, 
ROUND(MAX(`Life Expectancy`) - MIN(`Life Expectancy`), 1) AS Life_Exp_Range,
ROUND(AVG(GDP),1) AS GDP
From world_life_expectancy
WHERE `Life Expectancy` <> 0 
GROUP BY Country 
HAVING Life_Exp > 0 
AND GDP > 0 
ORDER BY Life_Exp DESC
LIMIT 10;


SELECT Year, 
round(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0 
GROUP BY Year 
ORDER By Year
;

SELECT 
Sum(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)  High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END),1)  High_GDP_Life_Expectancy,
Sum(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END)  Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END),1) Low_GDP_Life_Expectancy
FROM world_life_expectancy
Where GDP <> 0
ORDER BY GDP
;

SELECT STATUS, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status 
;

SELECT STATUS, COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status 
;

#Visualize this, seems like a cool graph. 
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI 
FROM world_life_expectancy
GROUP BY Country 
Having Life_Exp > 0 
AND BMI > 0 
ORDER BY BMI DESC
;

SELECT Country,
Year, 
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country Order By Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE 'United S%'
;


 


