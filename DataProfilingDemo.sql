
USE StackOverflow_201401
GO

/* Table metadata */
SELECT p.rows, t.*
FROM   sys.tables    t
JOIN   sys.partitions p ON  t.object_id = p.object_id
                        AND p.index_id = 1
WHERE  t.name = 'Posts' 
;

SELECT p.rows, t.*
FROM   sys.tables    t
JOIN   sys.partitions p ON  t.object_id = p.object_id
                        AND p.index_id = 1
WHERE  t.name = 'Users' 
;

/* View columns in the Posts table. */
SELECT c.object_id ,
       c.name ,
       c.column_id ,
       system_type = sys.name,
       user_type = typ.name ,
       CASE  
         WHEN sys.name = 'nvarchar' THEN c.max_length / 2
         WHEN sys.name = 'nchar' THEN c.max_length / 2
         ELSE c.max_length
       END AS max_length ,
       c.precision ,
       c.scale ,
       c.collation_name ,
       c.is_nullable
FROM   sys.tables t
JOIN   sys.columns c   ON  t.object_id = c.object_id
JOIN   sys.types   typ ON  c.system_type_id = typ.system_type_id
                       AND c.user_type_id = typ.user_type_id
JOIN   sys.types   sys ON  typ.system_type_id = sys.system_type_id
                       AND sys.user_type_id = sys.system_type_id
WHERE  t.name = 'Posts' 
;

/* Take a quick peek at the data */
SELECT TOP 100 *
FROM   Posts
;

SELECT TOP 100 *
FROM   Users
; 

/*   */
/* Min, Max, Mean, Median */
SELECT MinAge = (SELECT MIN(Age) FROM Users) ,
       MaxAge = (SELECT MAX(Age) FROM Users) ,
       MeanAge = (SELECT AVG(Age) FROM Users) ,
       MedianAge = (SELECT DISTINCT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Age) OVER() FROM Users)

/* */
/* Nulls. Why did it have to be nulls? */
SELECT    NumOfNulls = COUNT(*) ,
          NumOfRows = (SELECT COUNT(*) FROM Posts) ,
          Ratio = COUNT(*) / CAST((SELECT COUNT(*) FROM Posts) AS DECIMAL(12,4))
FROM      Posts
WHERE     ClosedDate IS NULL

SELECT    NumOfNulls = COUNT(*) ,
          NumOfRows = (SELECT COUNT(*) FROM Posts) ,
          Ratio = COUNT(*) / CAST((SELECT COUNT(*) FROM Posts) AS DECIMAL(12,4))
FROM      Posts
WHERE     AcceptedAnswerId IS NULL

/*  */
/* Distinct Values / Frequency Distribution */
SELECT    PostTypeId, 
          COUNT(*)
FROM      Posts
GROUP BY  PostTypeId
ORDER BY  PostTypeId

SELECT    Tags, 
          COUNT(*)
FROM      Posts
GROUP BY  Tags
ORDER BY  COUNT(*) DESC

/* Pattern Analysis */
/* Is the User Website Url valid? */
/* Maybe like will help */
SELECT   WebsiteUrl, COUNT(*)
FROM     Users
WHERE    WebsiteUrl LIKE 'http://%'
GROUP BY WebsiteUrl
ORDER BY COUNT(*) DESC

/* What about those urls that don't have http? */
SELECT   WebsiteUrl, COUNT(*)
FROM     Users
WHERE    WebsiteUrl NOT LIKE 'http%://%'
GROUP BY WebsiteUrl
ORDER BY COUNT(*) DESC

/* Find all users from 'West Virginia' and those that have a common mispelling */
SELECT   DisplayName,
         Location
FROM     Users  
WHERE    Location LIKE 'West Virgin[ia]%'
ORDER BY Location

/* Are there any phone numbers in the Locations? */
SELECT   DisplayName,
         Location
FROM     Users
WHERE    Location LIKE '%[0-9][0-9][0-9]%[0-9][0-9][0-9]%[0-9][0-9][0-9][0-9]%'

/* What we could really use is some Regular Expressions */

/* CLR? Are you crazy? */

/* Enable CLR */
sp_configure 'clr enabled' , 1
RECONFIGURE
GO

/* Load clr dll into SQL Server */
CREATE ASSEMBLY RegularExpressionFunctions from 'c:\data\clr\RegexSearch.dll'
GO

/* Create function to call the dll */
CREATE FUNCTION dbo.SearchRegexPattern(
  @pattern nvarchar(4000) ,
  @input nvarchar(4000) ,
  @options int
)RETURNS bit
AS EXTERNAL NAME RegularExpressionFunctions.RegularExpressionFunctions.RegExIsMatch
GO

/*
RegEx Options:
  None = 0,
  IgnoreCase = 1,
  Multiline = 2,
  ExplicitCapture = 4,
  Compiled = 8,
  Singleline = 16,
  IgnorePatternWhitespace = 32,
  RightToLeft = 64,
  ECMAScript = 256,
  CultureInvariant = 512
*/

/* Use RegEx to find valid urls */
SELECT     WebsiteUrl , 
           COUNT(*)
FROM       Users 
WHERE      dbo.SearchRegexPattern('^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?', WebsiteUrl , 1) = 1
GROUP BY   WebsiteUrl
ORDER BY   COUNT(*) DESC

/* Use RegEx to find invalid urls */
SELECT     WebsiteUrl , 
           COUNT(*)
FROM       Users 
WHERE      dbo.SearchRegexPattern('^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?', WebsiteUrl , 1) = 0
GROUP BY   WebsiteUrl
ORDER BY   COUNT(*) DESC

/* Table Analysis */
/* Identify Candidate Keys */
SELECT   COUNT(*), DisplayName
FROM     Users
GROUP BY DisplayName
HAVING   COUNT(*) > 1
ORDER BY COUNT(*) DESC
;

SELECT   COUNT(*), DisplayName, Location, WebsiteUrl
FROM     Users
GROUP BY DisplayName, Location, WebsiteUrl
HAVING   COUNT(*) > 1
ORDER BY COUNT(*) DESC
;

SELECT   COUNT(*), DisplayName, Location, WebsiteUrl, CreationDate
FROM     Users
GROUP BY DisplayName, Location, WebsiteUrl, CreationDate
HAVING   COUNT(*) > 1
ORDER BY COUNT(*) DESC
;

/* Verify Foreign Keys */ 
SELECT    p.PostTypeId , 
          pt.Type ,
          COUNT(*)
FROM      Posts       p
LEFT JOIN PostTypes   pt  ON  p.PostTypeId = pt.Id
GROUP BY  PostTypeId, 
          pt.Type
ORDER BY  PostTypeId
;

/* Normalize? */
SELECT    Tags, 
          COUNT(*)
FROM      Posts
GROUP BY  Tags
ORDER BY  COUNT(*) DESC
;

/* Find duplicate rows */
SELECT   COUNT(*), AboutMe , Age, CreationDate, DisplayName, DownVotes, EmailHash , 
         LastAccessDate, Location, Reputation, UpVotes, Views, WebsiteUrl, AccountId
FROM     Users
GROUP BY AboutMe , Age, CreationDate, DisplayName, DownVotes, EmailHash , 
         LastAccessDate, Location, Reputation, UpVotes, Views, WebsiteUrl, AccountId
HAVING   COUNT(*) > 1
ORDER BY COUNT(*) DESC

























/* Table Overview */
sp_dataprofile 'Users', 0

/* Column Detail */
sp_dataprofile 'Users', 1

/* Column Statistics */
sp_dataprofile 'Users', 2, @SampleValue = 10

/* Candidate Key Check */
sp_dataprofile 'Users', 3, 'DisplayName, Location, WebsiteUrl, CreationDate'

/* Column Value Distribution */
sp_dataprofile 'Posts', 4, 'PostTypeId'




