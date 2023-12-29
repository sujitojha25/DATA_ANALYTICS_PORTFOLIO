--ANALYSIS QUESTIONS
USE project;


SELECT * FROM [dbo].[ZomatoData1]



--ROLLING/MOVING COUNT OF RESTAURANTS IN INDIAN CITIES
SELECT [COUNTRY_NAME],[City],[Locality],COUNT([Locality]) TOTAL_REST,
SUM(COUNT([Locality])) OVER(PARTITION BY [City] ORDER BY [Locality] DESC)
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY  [COUNTRY_NAME],[City],[Locality]



--SEARCHING FOR PERCENTAGE OF RESTAURANTS IN ALL THE COUNTRIES
CREATE OR ALTER VIEW TOTAL_COUNT
AS
(
SELECT DISTINCT([COUNTRY_NAME]),COUNT(CAST([RestaurantID]AS NUMERIC)) OVER() TOTAL_REST
FROM [dbo].[ZomatoData1]
--ORDER BY 1
)
SELECT * FROM TOTAL_COUNT

FINAL QUERY AFTER CREATING VIEW
WITH CT1 AS
(
SELECT [COUNTRY_NAME], COUNT(CAST([RestaurantID]AS NUMERIC)) REST_COUNT
FROM [dbo].[ZomatoData1]
GROUP BY [COUNTRY_NAME]
)
SELECT A.[COUNTRY_NAME],A.[REST_COUNT] ,ROUND(CAST(A.[REST_COUNT] AS DECIMAL)/CAST(B.[TOTAL_REST]AS DECIMAL)*100,2)
FROM CT1 A JOIN TOTAL_COUNT B
ON A.[COUNTRY_NAME] = B.[COUNTRY_NAME]
ORDER BY 3 DESC



--WHICH COUNTRIES AND HOW MANY RESTAURANTS WITH PERCENTAGE PROVIDES ONLINE DELIVERY OPTION
CREATE OR ALTER VIEW COUNTRY_REST
AS(
SELECT [COUNTRY_NAME], COUNT(CAST([RestaurantID]AS NUMERIC)) REST_COUNT
FROM [dbo].[ZomatoData1]
GROUP BY [COUNTRY_NAME]
)
SELECT * FROM COUNTRY_REST
ORDER BY 2 DESC

SELECT A.[COUNTRY_NAME],COUNT(A.[RestaurantID]) TOTAL_REST, 
ROUND(COUNT(CAST(A.[RestaurantID] AS DECIMAL))/CAST(B.[REST_COUNT] AS DECIMAL)*100, 2)
FROM [dbo].[ZomatoData1] A JOIN COUNTRY_REST B
ON A.[COUNTRY_NAME] = B.[COUNTRY_NAME]
WHERE A.[Has_Online_delivery] = 'YES'
GROUP BY A.[COUNTRY_NAME],B.REST_COUNT
ORDER BY 2 DESC



--FINDING FROM WHICH CITY AND LOCALITY IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1
AS
(
SELECT [City],[Locality],COUNT([RestaurantID]) REST_COUNT
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY CITY,LOCALITY
--ORDER BY 3 DESC
)
SELECT [Locality],REST_COUNT FROM CT1 WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)



--TYPES OF FOODS ARE AVAILABLE IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1
AS
(
SELECT [City],[Locality],COUNT([RestaurantID]) REST_COUNT
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY CITY,LOCALITY
--ORDER BY 3 DESC
),
CT2 AS (
SELECT [Locality],REST_COUNT FROM CT1 WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
),
CT3 AS (
SELECT [Locality],[Cuisines] FROM [dbo].[ZomatoData1]
)
SELECT  A.[Locality], B.[Cuisines]
FROM  CT2 A JOIN CT3 B
ON A.Locality = B.[Locality]



--MOST POPULAR FOOD IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
CREATE VIEW VF 
AS
(
SELECT [COUNTRY_NAME],[City],[Locality],N.[Cuisines] FROM [dbo].[ZomatoData1]
CROSS APPLY (SELECT VALUE AS [Cuisines] FROM string_split([Cuisines],'|')) N
)

WITH CT1
AS
(
SELECT [City],[Locality],COUNT([RestaurantID]) REST_COUNT
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY CITY,LOCALITY
--ORDER BY 3 DESC
),
CT2 AS (
SELECT [Locality],REST_COUNT FROM CT1 WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
)
SELECT A.[Cuisines], COUNT(A.[Cuisines])
FROM VF A JOIN CT2 B
ON A.Locality = B.[Locality]
GROUP BY B.[Locality],A.[Cuisines]
ORDER BY 2 DESC



--WHICH LOCALITIES IN INDIA HAS THE LOWEST RESTAURANTS LISTED IN ZOMATO
WITH CT1 AS
(
SELECT [City],[Locality], COUNT([RestaurantID]) REST_COUNT
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY [City],[Locality]
-- ORDER BY 3 DESC
)
SELECT * FROM CT1 WHERE REST_COUNT = (SELECT MIN(REST_COUNT) FROM CT1) ORDER BY CITY



--HOW MANY RESTAURANTS OFFER TABLE BOOKING OPTION IN INDIA WHERE THE MAX RESTAURANTS ARE LISTED IN ZOMATO
WITH CT1 AS (
SELECT [City],[Locality],COUNT([RestaurantID]) REST_COUNT
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
GROUP BY CITY,LOCALITY
--ORDER BY 3 DESC
),
CT2 AS (
SELECT [Locality],REST_COUNT FROM CT1 WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1)
),
CT3 AS (
SELECT [Locality],[Has_Table_booking] TABLE_BOOKING
FROM [dbo].[ZomatoData1]
)
SELECT A.[Locality], COUNT(A.TABLE_BOOKING) TABLE_BOOKING_OPTION
FROM CT3 A JOIN CT2 B
ON A.[Locality] = B.[Locality]
WHERE A.TABLE_BOOKING = 'YES'
GROUP BY A.[Locality]



-- HOW RATING AFFECTS IN MAX LISTED RESTAURANTS WITH AND WITHOUT TABLE BOOKING OPTION (Connaught Place)
SELECT 'WITH_TABLE' TABLE_BOOKING_OPT,COUNT([Has_Table_booking]) TOTAL_REST, ROUND(AVG([Rating]),2) AVG_RATING
FROM [dbo].[ZomatoData1]
WHERE [Has_Table_booking] = 'YES'
AND [Locality] = 'Connaught Place'
UNION
SELECT 'WITHOUT_TABLE' TABLE_BOOKING_OPT,COUNT([Has_Table_booking]) TOTAL_REST, ROUND(AVG([Rating]),2) AVG_RATING
FROM [dbo].[ZomatoData1]
WHERE [Has_Table_booking] = 'NO'
AND [Locality] = 'Connaught Place'



--AVG RATING OF RESTS LOCATION WISE
SELECT [COUNTRY_NAME],[City],[Locality], 
COUNT([RestaurantID]) TOTAL_REST ,ROUND(AVG(CAST([Rating] AS DECIMAL)),2) AVG_RATING
FROM [dbo].[ZomatoData1]
GROUP BY [COUNTRY_NAME],[City],[Locality]
ORDER BY 4 DESC



--FINDING THE BEST RESTAURANTS WITH MODRATE COST FOR TWO IN INDIA HAVING INDIAN CUISINES
SELECT *
FROM [dbo].[ZomatoData1]
WHERE [COUNTRY_NAME] = 'INDIA'
AND [Has_Table_booking] = 'YES'
AND [Has_Online_delivery] = 'YES'
AND [Price_range] <= 3
AND [Votes] > 1000
AND [Average_Cost_for_two] < 1000
AND [Rating] > 4
AND [Cuisines] LIKE '%INDIA%'
CREATE TABLE ServicesA(
 S_ID				  int primary key,    --Services table
);
CREATE TABLE Photographer(
 pName                VARCHAR(50),
 S_ID				  INTEGER,
 PEmail               VARCHAR(50),        -- Photographers table 
 Pphone               INTEGER,
 accountsfacebook     VARCHAR(50),
 accountsinstgram     VARCHAR(50)
 
);

CREATE TABLE catering(
   catering_Name          VARCHAR(50),
   S_ID				      INTEGER,
   Cat_Email              VARCHAR(50),       --Catering table
   cat_phone              INTEGER

);

CREATE TABLE music(
   band_Name        VARCHAR(50),
   S_ID			    INTEGER,
   MEmail           VARCHAR(50),             --Musicians or Bands table
   Mphone           INTEGER

);

CREATE TABLE Decoration(
   DName              VARCHAR(50),
   S_ID		          INTEGER,
   DEmail             VARCHAR(50),          --Decorators table
   Dphone             INTEGER

);

CREATE TABLE venue(
   venue_Name           VARCHAR(50),
   S_ID		            INTEGER,
   VEmail               VARCHAR(50),      --Venue table
   Vphone               INTEGER,
   venue_location       VARCHAR(100)

);



CREATE TABLE CustomerA(
   CNamefirst         VARCHAR(30),
   CNamesecond        VARCHAR(30),
   C_ID				  int primary key ,    --Customers table
   CEmail             VARCHAR(50),
   Cphone             INTEGER,
   Gender             VARCHAR(10),
   B_ID               INTEGER 
);

 

CREATE TABLE EventA(
   EName          VARCHAR(30),
   EType          VARCHAR(40),
   E_ID           int primary key,          --Events table
   Startdate      VARCHAR(40) ,
   Enddate        VARCHAR(40) ,
   noofguests     INTEGER,
   B_ID           INTEGER 
   );
  
CREATE TABLE OrganizersA(
   OName         VARCHAR(30),
   O_ID          int primary key,
   OEmail        VARCHAR(50),              --Organizers table
   YearofBirth   INTEGER 
  
);
CREATE TABLE Budget(
   B_ID					int primary key,
   BType				VARCHAR(50),
   Discount			    VARCHAR(50),        
   Estimated_cost       decimal(10,2),      -- Budget table (paid by customers or Events)
   amount_paid			decimal(10,2),
   Total_Amount			decimal(10,2)

   );

CREATE TABLE Feedback(
   C_ID			INTEGER,  
   frating		INTEGER,                   --Feedback table
   fcomment     VARCHAR(100)
   
   
   );

CREATE TABLE Event_Services(          --junction table between event and services
   E_ID     INTEGER,
   S_ID		INTEGER
   
   ); 
CREATE TABLE Event_ORG(               --junction table between event and organizers
   E_ID     INTEGER,
   O_ID		INTEGER
   
   ); 
   
CREATE TABLE Event_Cust(               --junction table between event and customers
   E_ID     INTEGER,
   C_ID		INTEGER,
   fees      decimal(10,2)
   
   ); 

CREATE TABLE phone_Org(               --for multivalued attribute phone in Organizers table
   O_ID		INTEGER,
   phone    INTEGER
   
   );
   


   --Inserting values in table Photographer
INSERT INTO  Photographer VALUES ('bassam monuir', 30, 'bassammounir@gmail.com',0114557045,'bassam-photographer','bassam mounir');
INSERT INTO  Photographer VALUES ('haytham ammar', 31, 'haythamammar@gmail.com',0124457850,'haythamAmmar@photographer','Haytham ammar12');
INSERT INTO  Photographer VALUES ('farah studio', 32, 'farahphoto@gmail.com',0114557865,'farah_photography','farah studio');
INSERT INTO  Photographer VALUES ('salah ahmed', 33, 'salah123@gmail.com',0114557865,'salah_photo@photographer','salah ahmed');
INSERT INTO  Photographer VALUES ('sherif monuir', 34, 'sh.mmounir@gmail.com',0113677045,'sh.mounir-photographer','sherif mounir');
INSERT INTO  Photographer VALUES ('john youssef', 35, 'john1254@gmail.com',0124495750,'john@photographer','john youssef');
INSERT INTO  Photographer VALUES ('ghazal studio', 36, 'ghazal99@gmail.com',0114114765,'ghazal studio','ghazal_studio');
INSERT INTO  Photographer VALUES ('salah ezzeldin', 37, 'salahezzeldin@gmail.com',0114876565,'salah_ezzeldin@photographer','salah ezzeldin');


 --Inserting values in table venue 
INSERT INTO venue VALUES ('Azur', 40, 'azurbeach@gmail.com',01233457430,'stanly El gaish road');
INSERT INTO venue VALUES ('four seasons', 41, 'fourseasons@gmail.com',01113355440,'sanstfeno El gaish road');
INSERT INTO venue VALUES ('greek club', 42, 'greekclub@gmail.com',012339987,'bahary near qaitbay citadele');
INSERT INTO venue VALUES ('tulip', 43, 'tuliphotel@gmail.com',0123345908,'Roshdy El gaish road');
INSERT INTO venue VALUES ('sunrise', 44, 'sunrise@gmail.com',012332208,'Roshdy El gaish road');
INSERT INTO venue VALUES ('Hilton', 45, 'Hilton@gmail.com',19976,'sidibeshr');
INSERT INTO venue VALUES ('Sheraton', 46, 'Sheraton@gmail.com',0123168708,'elmontazah');



 --Inserting values in table catering 
INSERT INTO catering VALUES ('bouchee', 50, 'boucheekitchen@gmail.com',01287766531);
INSERT INTO catering VALUES ('zafraan and vinilia', 51, 'ZandFkitchen@gmail.com',01272270788);
INSERT INTO catering VALUES ('la poire', 52, 'lapoire@gmail.com',0127889632);
INSERT INTO catering VALUES ('brew&chew', 53, 'brew&chew@gmail.com',01116677542);
INSERT INTO catering VALUES ('Nutopia', 54, 'Nutopia@gmail.com',0127827942);
INSERT INTO catering VALUES ('Moullies', 55, 'Moullies@gmail.com',01108697542);


 --Inserting values in table Decoration 
INSERT INTO Decoration VALUES ('EL mansy Decor', 60, 'elmansydecoration@gmail.com',01116990542);
INSERT INTO Decoration VALUES ('layla events', 61, 'laylaevents@gmail.com',01286677542);
INSERT INTO Decoration VALUES ('pansee decoration', 62, 'pansee-decorgmail.com',01116677542);
INSERT INTO Decoration VALUES ('3M for events', 63, 'threeM-decor@gmail.com',01116677542);

 --Inserting values in table music 
INSERT INTO music VALUES ('masar egbari', 70, 'null',01116990542);
INSERT INTO music VALUES ('5altbeta band', 71, '5altabeta-band@gmail.com',01280077545);
INSERT INTO music VALUES ('west elbalad', 73, 'null',01216677765);
INSERT INTO music VALUES ('opera band', 74, 'opera-band@gmail.com',0100986500);
INSERT INTO music VALUES ('cairokee', 75, 'null',01586090542);
INSERT INTO music VALUES ('Sharmoofers', 76, 'Sharmoofers@gmail.com',01280048075);
INSERT INTO music VALUES ('Disco masr', 77, 'null',07775000);
INSERT INTO music VALUES ('fouad & mounib', 78, 'Null',0100379800);



--Inserting values in table CustomerA
INSERT INTO CustomerA VALUES ('khaled', 'zakaria', 20, 'khaledahmed11@gmail.com',01233457430,'male',1);
INSERT INTO CustomerA VALUES ('marwan', 'hazem', 21, 'marwanhazem45@gmail.com',01113355009,'male',2);
INSERT INTO CustomerA VALUES ('menna',' mohamed', 22, 'mennamo123@gmail.com',0109077885,'female',3);
INSERT INTO CustomerA VALUES ('noha', 'ahmed', 23, 'nohaahmed18@gmail.com',0114557865,'female',4);
INSERT INTO CustomerA VALUES ('medhat',' ahmed', 24, 'body33@gmail.com',01233555560,'male',5);
INSERT INTO CustomerA VALUES ('marwan ','hesham', 25, 'maro45o@gmail.com',01236355009,'male',6);
INSERT INTO CustomerA VALUES ('menna',' marghany', 26, 'mennamarghany@gmail.com',0114071285,'female',7);
INSERT INTO CustomerA VALUES ('sherine ','ahmed', 27, 'sherine@gmail.com',0114358865,'female',8);
INSERT INTO CustomerA VALUES ('saeed',' aly', 28, 'saeed1@gmail.com',01257037430,'male',9);
INSERT INTO CustomerA VALUES ('mariam ','hazem', 29, 'mariam@gmail.com',01169354308,'female',10);
INSERT INTO CustomerA VALUES ('marina',' atef', 30, 'marina@gmail.com',0109028505,'female',11);
INSERT INTO CustomerA VALUES ('hoda',' ahmed', 31, 'hoda32@gmail.com',0113064865,'female',12);
INSERT INTO CustomerA VALUES ('aya ','ali', 32, 'ayaali4556@gmail.com',01147802308,'female',13);
INSERT INTO CustomerA VALUES ('nada',' sameh', 33, 'nada_sameh23@gmail.com',0119044405,'female',14);
INSERT INTO CustomerA VALUES ('nadine',' ahmed', 34, 'nado@gmail.com',0114567865,'female',15);
INSERT INTO CustomerA VALUES ('mariam ','ahmed', 35, 'mariam@gmail.com',01169354308,'female',1);
INSERT INTO CustomerA VALUES ('samah',' amir', 36, 'samozain@gmail.com',0122978505,'female',2);
INSERT INTO CustomerA VALUES ('samira',' saeed', 37, 'samira21@gmail.com',0113064865,'female',3);
INSERT INTO CustomerA VALUES ('aly', 'amin', 38, 'alyyy382@gmail.com',01233490430,'male',4);
INSERT INTO CustomerA VALUES ('mohamed', 'ahmed', 39, 'mahamiho@gmail.com',0153657430,'male',5);
INSERT INTO CustomerA VALUES ('mahmoud', 'aly', 40, 'hoodaa234@gmail.com',01233245430,'male',6);



--Inserting values in table OrganizersA
INSERT INTO OrganizersA VALUES ('monica atef', 10, 'monicaatef98@gmail.com',1998);
INSERT INTO OrganizersA VALUES ('omar ibrahim', 11, 'omaribrahim12@gmail.com',1992);
INSERT INTO OrganizersA VALUES ('heba mohamed', 12, 'heba93mo@gmail.com',1993);
INSERT INTO OrganizersA VALUES ('lara ehab', 13, 'lara123@gmail.com',1989);
INSERT INTO OrganizersA VALUES ('essam ali', 14, 'essam32@gmail.com',1990);
INSERT INTO OrganizersA VALUES ('ahmed ibrahim', 15, 'ahmedibrahim132@gmail.com',1992);
INSERT INTO OrganizersA VALUES ('nada mohamed', 16, 'nada3894@gmail.com',1993);
INSERT INTO OrganizersA VALUES ('sara lara yara 5yara', 17, '5yara156@gmail.com',1989);
INSERT INTO OrganizersA VALUES ('ahmed ali', 18, 'ahmedali@gmail.com',1990);
INSERT INTO OrganizersA VALUES ('youssef mohamed', 19, 'youssef3469@gmail.com',1992);
INSERT INTO OrganizersA VALUES ('yara mohamed', 20, 'yaramohamed385@gmail.com',1993);
INSERT INTO OrganizersA VALUES ('saad saeed', 21, 'saad36@gmail.com',1989);




--Inserting values in table EventA
INSERT INTO EventA VALUES ('go cycle', 'sports', 1,'18-08-20','18-08-20',300,1);
INSERT INTO EventA VALUES ('omar khayrt concert', 'musical', 2,'18-08-20','18-08-20',340,2);
INSERT INTO EventA VALUES ('creative hands', 'Arts', 3,'20-09-20','21-09-20',200,3);
INSERT INTO EventA VALUES ('italian kitchen', 'food', 4,'9-06-20','9-06-20',400,4);
INSERT INTO EventA VALUES ('triple f', 'sports', 5,'18-08-20','18-08-20',500,6);
INSERT INTO EventA VALUES ('Assala concert', 'musical', 6,'18-08-20','18-08-20',340,5);
INSERT INTO EventA VALUES ('Color festival', 'Arts', 7,'20-09-20','21-09-20',200,7);
INSERT INTO EventA VALUES ('Cbc sofra', 'food', 8,'9-06-20','9-06-20',400,8);
INSERT INTO EventA VALUES ('Tycoons session', 'sports', 9,'18-08-20','18-08-20',300,10);
INSERT INTO EventA VALUES ('Sharmoofers', 'musical', 10,'18-08-20','18-08-20',340,11);
INSERT INTO EventA VALUES ('Drawing session', 'Arts', 11,'20-09-20','21-09-20',200,9);
INSERT INTO EventA VALUES ('Little chef', 'food', 12,'9-06-20','9-06-20',400,15);


--Inserting values in table Budget
INSERT INTO Budget VALUES (1, 'credit card', 'no discount',100,105,105);
INSERT INTO Budget VALUES (2, 'cash', '30%',150,200,170);
INSERT INTO Budget VALUES (3, 'cash', '10%',200,200,190);
INSERT INTO Budget VALUES (4, 'credit card', '40%',400,400,400);
INSERT INTO Budget VALUES (5, 'cash', '30%',100,200,105);
INSERT INTO Budget VALUES (6, 'credit card', 'no discount',150,155,155);
INSERT INTO Budget VALUES (7, 'credit card', 'no discount',100,200,105);
INSERT INTO Budget VALUES (8, 'cash', 'no discount',100,200,105);
INSERT INTO Budget VALUES (9, 'credit card', '50%',1000,1100,1100);
INSERT INTO Budget VALUES (10, 'cash', 'no discount',100,200,105);
INSERT INTO Budget VALUES (11, 'credit card', 'no discount',100,200,105);
INSERT INTO Budget VALUES (12, 'cash', '5%',100,200,105);
INSERT INTO Budget VALUES (13, 'cash', '20%',100,200,105);
INSERT INTO Budget VALUES (14, 'cash', 'no discount',100,200,105);
INSERT INTO Budget VALUES (15, 'credit card', '70%',100,200,105);


--Inserting values in junction table Event_Services
INSERT INTO Event_Services VALUES (1,30);
INSERT INTO Event_Services VALUES (1,41);
INSERT INTO Event_Services VALUES (3,50);
INSERT INTO Event_Services VALUES (4,60);
INSERT INTO Event_Services VALUES (10,70);
INSERT INTO Event_Services VALUES (10,54);
INSERT INTO Event_Services VALUES (12,62);
INSERT INTO Event_Services VALUES (11,44);



--Inserting values in junction table Event_ORG
INSERT INTO Event_ORG VALUES (1,10);
INSERT INTO Event_ORG VALUES (1,12);
INSERT INTO Event_ORG VALUES (2,13);
INSERT INTO Event_ORG VALUES (2,15);  
INSERT INTO Event_ORG VALUES (9,14);
INSERT INTO Event_ORG VALUES (7,20);
INSERT INTO Event_ORG VALUES (5,17);
INSERT INTO Event_ORG VALUES (5,19);



--Inserting values in junction table Event_Cust
INSERT INTO Event_Cust VALUES (1,20,300);
INSERT INTO Event_Cust VALUES (1,40,100);
INSERT INTO Event_Cust VALUES (1,33,300);
INSERT INTO Event_Cust VALUES (1,31,100);
INSERT INTO Event_Cust VALUES (1,30,300);
INSERT INTO Event_Cust VALUES (2,22,100);
INSERT INTO Event_Cust VALUES (2,23,300);
INSERT INTO Event_Cust VALUES (2,24,100);
INSERT INTO Event_Cust VALUES (2,25,300);
INSERT INTO Event_Cust VALUES (2,26,100);
INSERT INTO Event_Cust VALUES (3,28,300);
INSERT INTO Event_Cust VALUES (3,25,100);
INSERT INTO Event_Cust VALUES (3,20,300);
INSERT INTO Event_Cust VALUES (3,29,100);
INSERT INTO Event_Cust VALUES (3,23,300);
INSERT INTO Event_Cust VALUES (3,33,100);







--(phone numbers of Organizers)
INSERT INTO phone_Org VALUES (10,20242343);
INSERT INTO phone_Org VALUES (10,4043657);
INSERT INTO phone_Org VALUES (11,20457457);                   
INSERT INTO phone_Org VALUES (11,4045754);
INSERT INTO phone_Org VALUES (12,20242343);
INSERT INTO phone_Org VALUES (12,4043657);
INSERT INTO phone_Org VALUES (13,20457457);
INSERT INTO phone_Org VALUES (13,4045754);


--Inserting values in junction table Feedback
INSERT INTO Feedback VALUES (20,4,'way too crowded');
INSERT INTO Feedback VALUES (27,5,'no comment');
INSERT INTO Feedback VALUES (29,5,'no comment');
INSERT INTO Feedback VALUES (40,3,'it could longer');
INSERT INTO Feedback VALUES (30,2,'Bad organizing');
INSERT INTO Feedback VALUES (33,4,'good organizing');
