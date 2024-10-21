-- Ahmad Fakhouri c402

/*
Join Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     Also include the total records returned.
*/

USE orderbook_activity_db;


-- #1: Display the dateJoined and username for admin users.
SELECT 
    User.dateJoined, 
    User.uname AS username
FROM 
    User
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
WHERE 
    Role.name = 'admin';
/*
2023-02-14 13:13:28	admin
2023-04-01 13:13:28	wiley
2023-03-15 19:16:21	alice
Rows=3
*/

-- #2: Display each absolute order net (share*price), status, symbol, trade date, and username.
-- Sort the results with largest the absolute order net (share*price) at the top.
-- Include only orders that were not canceled or partially canceled.
SELECT 
    User.uname AS username, 
    `Order`.symbol, 
    `Order`.status, 
    ABS(`Order`.shares * `Order`.price) AS order_net, 
    `Order`.orderTime AS trade_date
FROM 
    `Order`
JOIN 
    User ON `Order`.userid = User.userid
WHERE 
    `Order`.status NOT IN ('canceled', 'canceled_partial_fill')
ORDER BY 
    order_net DESC;

/*
alice	SPY	partial_fill	36573.00	2023-03-15 19:24:21
kendra	SPY	filled	27429.75	2023-03-15 19:24:47
kendra	QQQ	pending	26827.00	2023-03-15 19:24:32
kendra	QQQ	pending	26827.00	2023-03-15 19:24:32
robert	NFLX	pending	24315.00	2023-03-15 19:21:12
Rows = 20
*/

-- #3: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Note that filledShares are the opposite sign (+-) because they subtract from ordershares!
SELECT 
    `Order`.orderid, 
    `Order`.symbol, 
    `Order`.status, 
    `Order`.shares AS order_shares, 
    - Fill.share AS filled_shares, 
    `Order`.price
FROM 
    `Order`
JOIN 
    Fill ON `Order`.orderid = Fill.orderid;

/*
1	WLY	partial_fill	100	10	38.73
2	WLY	filled	-10	-10	38.73
4	A	filled	10	10	129.89
5	A	filled	-10	-10	129.89
6	GS	canceled_partial_fill	100	10	305.63
Rows=14
*/

-- #4: Display all partial_fill orders and how many outstanding shares are left.
-- Also include the username, symbol, and orderid.
SELECT 
    User.uname AS username, 
    `Order`.orderid, 
    `Order`.symbol, 
    `Order`.shares - IFNULL(SUM(Fill.share), 0) AS outstanding_shares
FROM 
    `Order`
LEFT JOIN 
    Fill ON `Order`.orderid = Fill.orderid
JOIN 
    User ON `Order`.userid = User.userid
WHERE 
    `Order`.status = 'partial_fill'
GROUP BY 
    `Order`.orderid, `Order`.shares, User.uname, `Order`.symbol
HAVING 
    outstanding_shares > 0;
/*
admin	1	WLY	110
alice	11	SPY	175
Rows=2
*/
-- #5: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Also include the username, role, absolute net amount of shares filled, and absolute net order.
-- Sort by the absolute net order with the largest value at the top.
SELECT 
    `Order`.orderid, 
    `Order`.symbol, 
    `Order`.status, 
    `Order`.shares AS order_shares, 
    ABS(SUM(Fill.share)) AS filled_shares, 
    `Order`.price, 
    User.uname AS username, 
    Role.name AS role,
    ABS(SUM(Fill.share * Fill.price)) AS net_filled_amount,
    ABS(`Order`.shares * `Order`.price) AS net_order_amount
FROM 
    `Order`
JOIN 
    Fill ON `Order`.orderid = Fill.orderid
JOIN 
    User ON `Order`.userid = User.userid
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
GROUP BY 
    `Order`.orderid, `Order`.shares, `Order`.symbol, `Order`.price, User.uname, Role.name
ORDER BY 
    net_order_amount DESC;
/*
11	SPY	partial_fill	100	75	365.73	alice	admin	27429.75	36573.00
6	GS	canceled_partial_fill	100	10	305.63	admin	admin	3056.30	30563.00
14	SPY	filled	-75	75	365.73	kendra	user	27429.75	27429.75
1	WLY	partial_fill	100	10	38.73	admin	admin	387.30	3873.00
8	AAPL	filled	25	25	140.76	robert	user	3519.00	3519.00
Rows = 13
*/

-- #6: Display the username and user role for users who have not placed an order.
SELECT 
    User.uname AS username, 
    Role.name AS role
FROM 
    User
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
LEFT JOIN 
    `Order` ON User.userid = `Order`.userid
WHERE 
    `Order`.orderid IS NULL;
/*
sam	user
wiley	admin
Rows = 2
*/
-- #7: Display orderid, username, role, symbol, price, and number of shares for orders with no fills.
SELECT 
    `Order`.orderid, 
    User.uname AS username, 
    Role.name AS role, 
    `Order`.symbol, 
    `Order`.price, 
    `Order`.shares
FROM 
    `Order`
JOIN 
    User ON `Order`.userid = User.userid
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
LEFT JOIN 
    Fill ON `Order`.orderid = Fill.orderid
WHERE 
    Fill.fillid IS NULL;

/*
3	robert	user	NFLX	243.15	-100
12	kendra	user	QQQ	268.27	-100
13	kendra	user	QQQ	268.27	-100
17	robert	user	AAA	24.09	10
18	robert	user	MSFT	236.27	100
Rows = 11
*/

-- #8: Display the symbol, username, role, and number of filled shares where the order symbol is WLY.
-- Include all orders, even if the order has no fills.
SELECT 
    `Order`.symbol, 
    User.uname AS username, 
    Role.name AS role, 
    IFNULL(SUM(Fill.share), 0) AS filled_shares
FROM 
    `Order`
LEFT JOIN 
    Fill ON `Order`.orderid = Fill.orderid
JOIN 
    User ON `Order`.userid = User.userid
JOIN 
    UserRoles ON User.userid = UserRoles.userid
JOIN 
    Role ON UserRoles.roleid = Role.roleid
WHERE 
    `Order`.symbol = 'WLY'
GROUP BY 
    `Order`.symbol, User.uname, Role.name;

/*
WLY	admin	admin	-10
WLY	robert	user	10
WLY	james	user	0
Rows=3
*/


