-- Ahmad Fakhouri C402

/*
Aggregate Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     THEN records returned. 
*/

USE orderbook_activity_db;

-- #1: How many users do we have?
SELECT COUNT(*) FROM User;
/* 7 */


-- #2: List the username, userid, and number of orders each user has placed.
SELECT 
    User.uname AS username,
    User.userid,
    COUNT(`Order`.orderid) AS number_of_orders
FROM 
    User
LEFT JOIN 
    `Order` ON User.userid = `Order`.userid
GROUP BY 
    User.userid, User.uname;
/*
admin	1	3
alice	5	8
james	3	3
kendra	4	5
robert	6	5
Rows=7
*/

-- #3: List the username, symbol, and number of orders placed for each user and for each symbol. 
-- Sort results in alphabetical order by symbol.
SELECT  
    User.uname AS username,
    `Order`.symbol AS symbol,
    COUNT(`Order`.orderid) AS number_of_orders
FROM 
    User
JOIN 
    `Order` ON User.userid = `Order`.userid
GROUP BY 
    User.userid, User.uname, `Order`.symbol
ORDER BY 
    `Order`.symbol ASC;
/*
alice	A	5
james	A	1
robert	AAA	1
admin	AAPL	1
robert	AAPL	1
ROWS = 19
*/


-- #4: Perform the same query as the one above, but only include admin users.

SELECT  
    User.uname AS username,
    `Order`.symbol AS symbol,
    COUNT(`Order`.orderid) AS number_of_orders
FROM 
    User
JOIN 
    `Order` ON User.userid = `Order`.userid
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
WHERE 
    Role.name = 'admin'
GROUP BY 
    User.userid, User.uname, `Order`.symbol
ORDER BY 
    `Order`.symbol ASC;
/*
alice	A	5
admin	AAPL	1
alice	GOOG	1
admin	GS	1
alice	SPY	1 
Rows=7
*/
-- #5: List the username and the average absolute net order amount for each user with an order.
-- Round the result to the nearest hundredth and use an alias (averageTradePrice).
-- Sort the results by averageTradePrice with the largest value at the top.
SELECT  
    User.uname AS username,
    ROUND(AVG(ABS(`Order`.shares * `Order`.price)), 2) AS averageTradePrice
FROM 
    User
JOIN 
    `Order` ON User.userid = `Order`.userid
GROUP BY 
    User.userid, User.uname
HAVING 
    COUNT(`Order`.orderid) > 0
ORDER BY 
    averageTradePrice DESC;
/*
kendra	17109.53
admin	12182.47
robert	10417.84
alice	6280.26
james	2053.73
Rows=5
*/

-- #6: How many shares for each symbol does each user have?
-- Display the username and symbol with number of shares.
SELECT  
    User.uname AS username,
    `Order`.symbol AS symbol,
    SUM(`Order`.shares) AS total_shares
FROM 
    User
JOIN 
    `Order` ON User.userid = `Order`.userid
GROUP BY 
    User.userid, `Order`.symbol;
/*
admin	WLY	100
admin	GS	100
admin	AAPL	-15
alice	A	18
alice	SPY	100
Rows=19
*/


-- #7: What symbols have at least 3 orders?
SELECT 
    symbol,
    COUNT(orderid) AS number_of_orders
FROM 
    `Order`
GROUP BY 
    symbol
HAVING 
    COUNT(orderid) >= 3;
/*
A	6
AAPL	3
WLY	3
Rows=3
*/

-- #8: List all the symbols and absolute net fills that have fills exceeding $100.
-- Do not include the WLY symbol in the results.
-- Sort the results by highest net with the largest value at the top.
SELECT  
    Fill.symbol,
    SUM(ABS(Fill.share * Fill.price)) AS net_fill
FROM 
    Fill
WHERE 
    Fill.symbol != 'WLY'
GROUP BY 
    Fill.symbol
HAVING 
    net_fill > 100
ORDER BY 
    net_fill DESC;
/*
SPY	54859.50
AAPL	7038.00
GS	6112.60
A	2597.80
TLT	1978.60
Rows = 5
*/

-- #9: List the top five users with the greatest amount of outstanding orders.
-- Display the absolute amount filled, absolute amount ordered, and net outstanding.
-- Sort the results by the net outstanding amount with the largest value at the top.
SELECT  
    User.uname AS username,
    SUM(ABS(Fill.share)) AS total_filled,
    SUM(ABS(`Order`.shares)) AS total_ordered,
    (SUM(ABS(`Order`.shares)) - SUM(ABS(Fill.share))) AS net_outstanding
FROM 
    User
JOIN 
    `Order` ON User.userid = `Order`.userid
LEFT JOIN 
    Fill ON `Order`.orderid = Fill.orderid
GROUP BY 
    User.userid
ORDER BY 
    net_outstanding DESC
LIMIT 5;
/*
robert	35	270	235
kendra	95	295	200
admin	35	215	180
alice	95	230	135
james	20	120	100
Rows=5
*/