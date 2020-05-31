Use Northwind

DECLARE
  @date DATETIME= CONVERT(DATETIME, '5/6/1998', 101)

/* 1.1	������� � ������� Orders ������, ������� ���� ���������� ����� 6 ��� 1998 ���� (������� ShippedDate) ������������ � ������� ���������� � ShipVia >= 2. ������ �������� ���� ������ ���� ������ ��� ����� ������������ ����������, �������� ����������� ������ �Writing International Transact-SQL Statements� � Books Online ������ �Accessing and Changing Relational Data Overview�. ���� ����� ������������ ����� ��� ���� �������. ������ ������ ����������� ������ ������� OrderID, ShippedDate � ShipVia. 
		�������� ������ ���� �� ������ ������ � NULL-�� � ������� ShippedDate. 
		NULL �������� �����, ������� �� ����� ������� ��������. ��� ���������� �������� � ���-�� */
SELECT OrderID, ShippedDate, ShipVia  FROM dbo.Orders
WHERE ShippedDate >= @date AND ShipVia >= 2

/* 1.2	�������� ������, ������� ������� ������ �������������� ������ �� ������� Orders. � ����������� ������� ����������� ��� ������� ShippedDate ������ �������� NULL ������ �Not Shipped� � ������������ ��������� ������� CAS�. ������ ������ ����������� ������ ������� OrderID � ShippedDate. */
SELECT OrderID,
	CASE 
		WHEN ShippedDate IS NULL THEN 'Not Shipped'
	END AS ShippedDate
FROM dbo.Orders
WHERE ShippedDate IS NULL

/*1.3	������� � ������� Orders ������, ������� ���� ���������� ����� 6 ��� 1998 ���� (ShippedDate) �� ������� ��� ���� ��� ������� ��� �� ����������. � ������� ������ ������������� ������ ������� OrderID (������������� � Order Number) � ShippedDate (������������� � Shipped Date). � ����������� ������� ����������� ��� ������� ShippedDate ������ �������� NULL ������ �Not Shipped�, ��� ��������� �������� ����������� ���� � ������� �� ���������. */
SELECT OrderID AS 'Order Number',
	CASE WHEN ShippedDate IS NULL THEN 'Not Shipped'
		 ELSE CONVERT(VARCHAR(10), ShippedDate, 101)
	END AS 'Shipped Date'

FROM dbo.Orders
WHERE ShippedDate > @date OR ShippedDate IS NULL

/* 2.1	������� �� ������� Customers ���� ����������, ����������� � USA � Canada. ������ ������� � ������ ������� ��������� IN. ����������� ������� � ������ ������������ � ��������� ������ � ����������� �������. ����������� ���������� ������� �� ����� ���������� � �� ����� ����������. */
SELECT ContactName, Country FROM Customers
WHERE Country IN('USA', 'Canada')
ORDER BY ContactName, Country

/* 2.2	������� �� ������� Customers ���� ����������, �� ����������� � USA � Canada. ������ ������� � ������� ��������� IN. ����������� ������� � ������ ������������ � ��������� ������ � ����������� �������. ����������� ���������� ������� �� ����� ����������. */
SELECT ContactName, Country FROM Customers
WHERE Country NOT IN('USA', 'Canada')
ORDER BY ContactName

/* 2.3	������� �� ������� Customers ��� ������, � ������� ��������� ���������. ������ ������ ���� ��������� ������ ���� ��� � ������ ������������ �� ��������. �� ������������ ����������� GROUP BY. ����������� ������ ���� ������� � ����������� �������.  */
SELECT DISTINCT Country FROM Customers
ORDER BY Country DESC

/* 3.1	������� ��� ������ (OrderID) �� ������� Order Details (������ �� ������ �����������), ��� ����������� �������� � ����������� �� 3 �� 10 ������������ � ��� ������� Quantity � ������� Order Details. ������������ �������� BETWEEN. ������ ������ ����������� ������ ������� OrderID. */
SELECT DISTINCT OrderID FROM [Order Details]
WHERE Quantity BETWEEN 3 AND 10

/* 3.2	������� ���� ���������� �� ������� Customers, � ������� �������� ������ ���������� �� ����� �� ��������� b � g. ������������ �������� BETWEEN. ���������, ��� � ���������� ������� �������� Germany. ������ ������ ����������� ������ ������� CustomerID � Country � ������������ �� Country. 
������ 2: ��������� ������� (�� ��������� � ������): 35% */
SELECT CustomerID, Country FROM Customers
WHERE SUBSTRING(Country, 1, 1) BETWEEN 'b' AND 'g'
ORDER BY Country

/*  3.3	������� ���� ���������� �� ������� Customers, � ������� �������� ������ ���������� �� ����� �� ��������� b � g, �� ��������� �������� BETWEEN. � ������� ����� �Execution Plan� ���������� ����� ������ ���������������� 3.2 ��� 3.3 � ��� ����� ���� ������ � ������ ���������� ���������� Execution Plan-a ��� ���� ���� ��������, ���������� ���������� Execution Plan ���� ������ � ������ � ���� ����������� � �� �� ����������� ���� ����� �� ������ � �� ������ ��������� ���� ��������� ���������. ������ ������ ����������� ������ ������� CustomerID � Country � ������������ �� Country.
������ 3: ��������� ������� (�� ��������� � ������): 35% */
SELECT CustomerID, Country FROM Customers
WHERE SUBSTRING(Country, 1, 1) >= 'b' AND SUBSTRING(Country, 1, 1) <= 'g'
ORDER BY Country

/* 4.1	� ������� Products ����� ��� �������� (������� ProductName), ��� ����������� ��������� 'chocolade'. ��������, ��� � ��������� 'chocolade' ����� ���� �������� ���� ����� 'c' � �������� - ����� ��� ��������, ������� ������������� ����� �������. ���������: ���������� ������� ������ ����������� 2 ������. */
SELECT ProductID, ProductName FROM Products
WHERE ProductName LIKE '%cho_olade%'

/* 5.1	����� ����� ����� ���� ������� �� ������� Order Details � ������ ���������� ����������� ������� � ������ �� ���. ��������� ��������� �� ����� � ��������� � ����� 1 ��� ���� ������ money.  ������ (������� Discount) ���������� ������� �� ��������� ��� ������� ������. ��� ����������� �������������� ���� �� ��������� ������� ���� ������� ������ �� ��������� � ������� UnitPrice ����. ����������� ������� ������ ���� ���� ������ � ����� �������� � ��������� ������� 'Totals'. */
SELECT ROUND(SUM(UnitPrice * (1 - Discount) * Quantity), 2) AS 'Totals'
FROM [Order Details]

/* 5.2	�� ������� Orders ����� ���������� �������, ������� ��� �� ���� ���������� (�.�. � ������� ShippedDate ��� �������� ���� ��������). ������������ ��� ���� ������� ������ �������� COUNT. �� ������������ ����������� WHERE � GROUP. */
SELECT COUNT(*) - COUNT(ShippedDate) AS 'Not delivered count' 
FROM Orders

/* 5.3	�� ������� Orders ����� ���������� ��������� ����������� (CustomerID), ��������� ������. ������������ ������� COUNT � �� ������������ ����������� WHERE � GROUP. */
SELECT Count(CustomerID) AS 'Number of customers'
FROM Orders

/* 6.1	�� ������� Orders ����� ���������� ������� � ������������ �� �����. � ����������� ������� ���� ����������� ��� ������� c ���������� Year � Total. �������� ����������� ������, ������� ��������� ���������� ���� �������. */
SELECT YEAR(OrderDate) AS 'Year', COUNT(OrderID) AS 'Total' 
FROM Orders
GROUP BY YEAR(OrderDate)

/* ���� �������.
6.2	�� ������� Orders ����� ���������� �������, c�������� ������ ���������. ����� ��� ���������� �������� � ��� ����� ������ � ������� Orders, ��� � ������� EmployeeID ������ �������� ��� ������� ��������. � ����������� ������� ���� ����������� ������� � ������ �������� (������ ������������� ��� ���������� ������������� LastName & FirstName. ��� ������ LastName & FirstName ������ ���� �������� ��������� �������� � ������� ��������� �������. ����� �������� ������ ������ ������������ ����������� �� EmployeeID.) � ��������� ������� �Seller� � ������� c ����������� ������� ����������� � ��������� 'Amount'. ���������� ������� ������ ���� ����������� �� �������� ���������� �������.  */
SELECT 
	(SELECT CONCAT(FirstName, ' ', LastName) FROM Employees
	WHERE Orders.EmployeeID = Employees.EmployeeID) AS 'Seller',
COUNT(Orders.OrderID) AS 'Amount'
FROM Orders
GROUP BY EmployeeID
ORDER BY 'Amount' DESC

/* 6.3	�� ������� Orders ����� ���������� �������, c�������� ������ ��������� � ��� ������� ����������. ���������� ���������� ��� ������ ��� ������� ��������� � 1998 ����. � ����������� ������� ���� ����������� ������� � ������ �������� (�������� ������� �Seller�), ������� � ������ ���������� (�������� ������� �Customer�)  � ������� c ����������� ������� ����������� � ��������� 'Amount'. � ������� ���������� ������������ ����������� �������� ����� T-SQL ��� ������ � ���������� GROUP (���� �� �������� ������� �������� ������ �ALL� � ����������� �������). ����������� ������ ���� ������� �� ID �������� � ����������. ���������� ������� ������ ���� ����������� �� ��������, ���������� � �� �������� ���������� ������. � ����������� ������ ���� ������� ���������� �� ��������. �.�. � ������������� ������ ������ �������������� ������������� � ���������� � �������� �������� ��� ������� ���������� ��������� �������: */
DECLARE
	@year INT = 1998

SELECT ISNULL( cast(Seller AS varchar(50)),
			   IIF(GROUPING(Seller) = 1, 'ALL', Seller)) AS Seller,

	   ISNULL( cast(ContactName AS varchar(50)),
			   IIF(GROUPING(ContactName) = 1, 'ALL', ContactName)) AS Customer,

	   COUNT(Orders.OrderID) AS Amount
FROM Orders

JOIN (SELECT EmployeeID, FirstName + ' ' + LastName AS Seller FROM Employees) AS S 
ON S.EmployeeID = Orders.EmployeeID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID

WHERE YEAR(Orders.OrderDate) = @year
GROUP BY CUBE(Seller, ContactName)
ORDER BY Amount DESC, S.Seller, Customer

/* 6.4	����� ����������� � ���������, ������� ����� � ����� ������. ���� � ������ ����� ������ ���� ��� ��������� ��������� ��� ������ ���� ��� ��������� �����������, �� ���������� � ����� ���������� � ��������� �� ������ �������� � �������������� �����. �� ������������ ����������� JOIN. � ����������� ������� ���������� ������� ��������� ��������� ��� ����������� �������: �Person�, �Type� (����� ���� �������� ������ �Customer� ���  �Seller� � ��������� �� ���� ������), �City�. ������������� ���������� ������� �� ������� �City� � �� �Person�. */
SELECT FirstName + ' ' + LastName AS Person,
	   'Seller' AS [Type],
	   City

FROM Employees 
WHERE EXISTS (SELECT City FROM Customers 
			  WHERE Employees.City = Customers.City)
UNION
SELECT ContactName AS Person, 'Customer' AS [Type], City
FROM Customers
WHERE EXISTS(SELECT City FROM Employees
			 WHERE Employees.City = Customers.City)
ORDER BY City, Person

/* 6.5	����� ���� �����������, ������� ����� � ����� ������. � ������� ������������ ���������� ������� Customers c ����� - ��������������. ��������� ������� CustomerID � City. ������ �� ������ ����������� ����������� ������. ��� �������� �������� ������, ������� ����������� ������, ������� ����������� ����� ������ ���� � ������� Customers. ��� �������� ��������� ������������ �������. */
USE Northwind

SELECT CustomerID, City
FROM Customers AS CustomerFirst
WHERE EXISTS(SELECT CustomerID AS CID, City FROM Customers AS CustomerSecond
			 WHERE not(CustomerFirst.CustomerID = CustomerSecond.CustomerID) AND 
					   CustomerFirst.City = CustomerSecond.City)
Order by City

/* 6.6	�� ������� Employees ����� ��� ������� �������� ��� ������������, �.�. ���� �� ������ �������. ��������� ������� � ������� 'User Name' (LastName) � 'Boss'. � �������� ������ ���� ��������� ����� �� ������� LastName. ��������� �� ��� �������� � ���� �������? 
���� �������� �� ���������� �.� �� ����� � ���� ReportsTo(NULL)*/
SELECT 
Employee.EmployeeID,
	LastName AS 'User Name',
	   Boss AS 'Boss'
FROM Employees AS Employee

JOIN (SELECT EmployeeID, LastName as Boss FROM Employees) AS B ON Employee.ReportsTo = B.EmployeeID
ORDER BY Boss

/* 7.1 ���������� ���������, ������� ����������� ������ 'Western' (������� Region). ���������� ������� ������ ����������� ��� ����: 'LastName' �������� � �������� ������������� ���������� ('TerritoryDescription' �� ������� Territories). ������ ������ ������������ JOIN � ����������� FROM. ��� ����������� ������ ����� ��������� Employees � Territories ���� ������������ ����������� ��������� ��� ���� Northwind. */
SELECT LastName,
	   TerritoryDescription
FROM Employees
JOIN EmployeeTerritories ON EmployeeTerritories.EmployeeID = Employees.EmployeeID
JOIN Territories ON Territories.TerritoryID = EmployeeTerritories.TerritoryID
JOIN Region ON Region.RegionID = Territories.RegionID
WHERE RegionDescription = 'Western'

/* 8.1	��������� � ����������� ������� ����� ���� ���������� �� ������� Customers � ��������� ���������� �� ������� �� ������� Orders. ������� �� ��������, ��� � ��������� ���������� ��� �������, �� ��� ����� ������ ���� �������� � ����������� �������. ����������� ���������� ������� �� ����������� ���������� �������.*/
SELECT ContactName, Count(Orders.OrderID) as 'Count'  
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY ContactName
ORDER BY Count

/* 9.1 ��������� ���� ����������� ������� CompanyName � ������� Suppliers, � ������� ��� ���� �� ������ �������� �� ������ (UnitsInStock � ������� Products ����� 0). ������������ ��������� SELECT ��� ����� ������� � �������������� ��������� IN. 
����� �� ������������ ������ ��������� IN �������� '=' ? - ����� WHERE UnitsInStock = 0 */
SELECT CompanyName
FROM Suppliers
JOIN Products  ON Products.SupplierID = Suppliers.SupplierID
WHERE UnitsInStock in ( SELECT UnitsInStock FROM Products WHERE UnitsInStock = 0)

/* 10.1	��������� ���� ���������, ������� ����� ����� 150 �������. ������������ ��������� ��������������� SELECT.*/
SELECT LastName FROM Employees
WHERE EmployeeID IN 
(SELECT EmployeeID FROM Orders
 GROUP BY EmployeeID
 HAVING COUNT(OrderID) > 150)

/* 11.1	��������� ���� ���������� (������� Customers), ������� �� ����� �� ������ ������ (��������� �� ������� Orders). ������������ ��������������� SELECT � �������� EXISTS. */
SELECT ContactName
FROM Customers
WHERE NOT EXISTS(SELECT CustomerID FROM Orders
			 WHERE Orders.CustomerID = Customers.CustomerID
			 GROUP BY Orders.CustomerID
			 HAVING Count(OrderID) > 0)

/* 12.1	��� ������������ ����������� ��������� Employees ��������� �� ������� Employees ������ ������ ��� ���� ��������, � ������� ���������� ������� Employees (������� LastName ) �� ���� �������. ���������� ������ ������ ���� ������������ �� �����������. */
SELECT DISTINCT SUBSTRING(LastName, 1, 1) AS FirstSymb
FROM Employees
ORDER BY FirstSymb

-- ������� ������������� ��������:
EXECUTE GreatestOrders 1996
EXECUTE ShippedOrdersDiff 15
EXECUTE SubordinationInfo_Print 5

-- ������ ������������� �������
SELECT LastName FROM Employees WHERE dbo.IsBoss(EmployeeID) != 0

