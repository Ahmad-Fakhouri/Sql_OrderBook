-- Ahmad Fakhouri c402

/*
Basic Selects

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     Also include the total records returned.
*/

USE orderbook_activity_db;

-- #1: List all users, including username and dateJoined.
SELECT uname AS username, dateJoined
FROM User;
/*
admin	2023-02-14 13:13:28
wiley	2023-04-01 13:13:28
james	2023-03-15 19:15:48
kendra	2023-03-15 19:16:06
alice	2023-03-15 19:16:21
Rows = 7
*/

-- #2: List the username and datejoined from users with the newest users at the top.
SELECT uname AS username, dateJoined
FROM User
ORDER BY dateJoined DESC;
/*
wiley	2023-04-01 13:13:28
sam	2023-03-15 19:16:59
robert	2023-03-15 19:16:43
alice	2023-03-15 19:16:21
kendra	2023-03-15 19:16:06
Rows=7
*/

-- #3: List all usernames and dateJoined for users who joined in March 2023.
SELECT uname AS username, dateJoined
FROM User
WHERE dateJoined BETWEEN '2023-03-01' AND '2023-03-31';
/*
james	2023-03-15 19:15:48
kendra	2023-03-15 19:16:06
alice	2023-03-15 19:16:21
robert	2023-03-15 19:16:43
sam	2023-03-15 19:16:59
Rows=5
*/

-- #4: List the different role names a user can have.
SELECT DISTINCT Role.name
FROM Role;
/*
admin
it
user
Rows=3
*/
-- #5: List all the orders.
SELECT *
FROM `Order`;
/*
1	1	WLY	1	2023-03-15 19:20:35	100	38.73	partial_fill
2	6	WLY	2	2023-03-15 19:20:50	-10	38.73	filled
3	6	NFLX	2	2023-03-15 19:21:12	-100	243.15	pending
4	5	A	1	2023-03-15 19:21:31	10	129.89	filled
5	3	A	2	2023-03-15 19:21:39	-10	129.89	filled
Rows=24
*/
-- #6: List all orders in March where the absolute net order amount is greater than 1000.
SELECT orderid, userid, symbol, shares, price, ABS(shares * price) AS net_order_amount
FROM `Order`
WHERE orderTime BETWEEN '2023-03-01' AND '2023-03-31'
  AND ABS(shares * price) > 1000;
/*
1	1	WLY	100	38.73	3873.00
3	6	NFLX	-100	243.15	24315.00
4	5	A	10	129.89	1298.90
5	3	A	-10	129.89	1298.90
6	1	GS	100	305.63	30563.00
Rows = 16
*/

-- #7: List all the unique status types from orders.
SELECT DISTINCT status
FROM `Order`;

/*
partial_fill
filled
pending
canceled_partial_fill
canceled
Rows=5
*/

-- #8: List all pending and partial fill orders with oldest orders first.

SELECT orderid, userid, symbol, orderTime, status
FROM `Order`
WHERE status IN ('pending', 'partial_fill')
ORDER BY orderTime ASC;
/*
1	1	WLY	2023-03-15 19:20:35	partial_fill
3	6	NFLX	2023-03-15 19:21:12	pending
11	5	SPY	2023-03-15 19:24:21	partial_fill
12	4	QQQ	2023-03-15 19:24:32	pending
13	4	QQQ	2023-03-15 19:24:32	pending
Rows=10
*/

-- #9: List the 10 most expensive financial products where the productType is stock.
-- Sort the results with the most expensive product at the top
SELECT symbol, price
FROM Product
WHERE productType = 'stock'
ORDER BY price DESC
LIMIT 10;
/*
207940.KS	830000.00
003240.KS	715000.00
000670.KS	630000.00
010130.KS	616000.00
006400.KS	605000.00
Rows=10

*/
-- #10: Display orderid, fillid, userid, symbol, and absolute net fill amount
-- from fills where the absolute net fill is greater than $1000.
-- Sort the results with the largest absolute net fill at the top.
SELECT 
    Fill.orderid, 
    Fill.fillid, 
    Fill.userid, 
    Fill.symbol, 
    ABS(Fill.share * Fill.price) AS net_fill_amount
FROM 
    Fill
WHERE 
    ABS(Fill.share * Fill.price) > 1000
ORDER BY 
    net_fill_amount DESC;
/*
11	11	5	SPY	27429.75
14	12	4	SPY	27429.75
6	5	1	GS	3056.30
7	6	4	GS	3056.30
8	9	6	AAPL	2111.40
Rows = 10
*/