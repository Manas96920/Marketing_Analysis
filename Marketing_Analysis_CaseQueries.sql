
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

-- Query to categorize the products based on their price
SELECT
	ProductID, -- Unique identifier of each product
	ProductName, -- Name of each product
	CONCAT('$',' ',Price) Price, -- Price of each prodct with dollar sign conatenated
	CASE -- Categorized the products into price categories: Low, Medium, High
		WHEN Price < 50 THEN 'Low' -- Low for product price below 50
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium' -- Medium for product price between 50 and 200
		ELSE 'High' -- High for product price above 200
	END PriceCategory
FROM dbo.products -- Source table

-- SQL query to join customer table with geography table to add locations for customers

SELECT
	c.CustomerID,
	c.CustomerName,
	c.Email,
	c.Gender,
	c.Age,
	g.City,
	g.Country
FROM dbo.customers c
LEFT JOIN dbo.geography g 
ON g.GeographyID = c.GeographyID

-- SQL query to clean whitespace issues in the ReviewText column

SELECT
	ReviewID,
	CustomerID,
	ProductID,
	ReviewDate,
	Rating,
	REPLACE(ReviewText,'  ',' ') AS ReviewText
FROM dbo.customer_reviews

-- SQL query to normalize the engagement data table

SELECT
	FORMAT(CONVERT(DATE,EngagementDate),'dd-MM-yyyy') EngagementDate,
	EngagementID,
	CampaignID,
	ProductID,
	ContentID,
	UPPER(REPLACE(ContentType,'Socialmedia','Social Media')) ContentType,
	LEFT(ViewsClicksCombined,CHARINDEX('-',ViewsClicksCombined)-1) Views,
	RIGHT(ViewsClicksCombined,LEN(ViewsClicksCombined)-CHARINDEX('-',ViewsClicksCombined)) Clicks,
	Likes
FROM dbo.engagement_data

-- SQL query to identify and tag duplicate records

WITH Duplicate_Records AS
(SELECT
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	UPPER(Stage) Stage,
	Action,
	Duration,
	AVG(Duration) OVER(PARTITION BY VisitDate) Avg_Duration,
	ROW_NUMBER() OVER(PARTITION BY CustomerID,ProductID,VisitDate,UPPER(Stage),Action ORDER BY JourneyID ASC) Row_Num
FROM dbo.customer_journey) 
SELECT 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, Avg_Duration) Duration
FROM Duplicate_Records WHERE Row_Num = 1

--OR

SELECT 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, Avg_Duration) Duration
FROM
(SELECT
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	UPPER(Stage) Stage,
	Action,
	Duration,
	AVG(Duration) OVER(PARTITION BY VisitDate) Avg_Duration,
	ROW_NUMBER() OVER(PARTITION BY CustomerID,ProductID,VisitDate,UPPER(Stage),Action ORDER BY JourneyID ASC) Row_Num
FROM dbo.customer_journey) AS SubQuery WHERE Row_Num = 1
