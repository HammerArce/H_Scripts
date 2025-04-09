--https://www.simboli.eu/p/DELETE_TABLE_JOIN_SQL_SERVER

/*How to DELETE with JOIN
Example 1
Let's assume we have a #Students table and we want to DELETE the rows that match with the #Rejected table.*/

CREATE TABLE #Students(
[Name] varchar(50),
[Surname] varchar(50),
[Period] int,
[Sport] int,
[History] int,
[English] int,
[Geography] int)

INSERT INTO
#Students([Name],[Surname],[Period],[Sport],[History],[English],[Geography])
VALUES
('Luke','Green',1,30,20,23,NULL),
('Mary','Brown',1,17,15,NULL,30),
('John','Red',1,18,NULL,21,30),
('Walter','White',1,22,20,5,30),
('Luke','Green',2,30,20,23,NULL),
('Mary','Brown',2,NULL,15,17,30),
('John','Red',2,18,NULL,11,30),
('Walter','White',2,2,32,1,30),
('Luke','Green',3,20,15,15,12),
('Mary','Brown',3,0,3,NULL,4),
('John','Red',3,18,40,21,30),
('Walter','White',3,17,19,15,30),
('John','Red',3,NULL,23,23,30);

CREATE TABLE #Rejected(
[Name] varchar(50),
[Surname] varchar(50))

INSERT INTO
#Rejected([Name],[Surname])
VALUES
('John','Red'),
('Walter','White');



DELETE A
FROM #Students A
INNER JOIN #Rejected B
ON A.[Name]=B.[Name]
AND A.[Surname]=B.[Surname]