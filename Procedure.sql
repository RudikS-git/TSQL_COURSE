USE [Northwind]

/* 13.1	�������� ���������, ������� ���������� ����� ������� ����� ��� ������� �� ��������� �� ������������ ���. 
		� ����������� �� ����� ���� ��������� ������� ������ ��������, ������ ���� ������ ���� � ����� �������. 
		� ����������� ������� ������ ���� �������� ��������� �������: ������� � ������ � �������� �������� (FirstName � LastName � ������: Nancy Davolio), ����� ������ � ��� ���������. 
		� ������� ���� ��������� Discount ��� ������� �������. 
		��������� ���������� ���, �� ������� ���� ������� �����, � ���������� ������������ �������. 
		���������� ������� ������ ���� ����������� �� �������� ����� ������. 
		��������� ������ ���� ����������� � �������������� ��������� SELECT � ��� ������������� ��������. 
		�������� ������� �������������� GreatestOrders. ���������� ������������������ ������������� ���� ��������. 
		����� ������ ������������ ������� �������� � ������� Query.sql ���� �������� ��������� �������������� ����������� ������ ��� ������������ ������������ ������ ��������� GreatestOrders. ����������� ������ ������ �������� � ������� ��� ��������� � ������������ ������ �������� ���� ��� ������������� �������� ��� ���� ��� ������� �� ������������ ��������� ��� � ����������� ��������� �������: ��� ��������, ����� ������, ����� ������. ����������� ������ �� ������ ��������� ������, ���������� � ���������, - �� ������ ��������� ������ ��, ��� ������� � ����������� �� ����.
		��� ������� �� ������ �������� ������ ���� �������� � ����� Query.sql � ��. ��������� ���� � ������� ����������� � �����������.*/
GO
CREATE PROCEDURE GreatestOrders
	@Year INT
AS BEGIN

SELECT (SELECT CONCAT(FirstName, ' ', LastName) FROM Employees WHERE Employees.EmployeeID = Orders.EmployeeID), 
		Orders.EmployeeID, 
		MAX(UnitPrice * (1 - Discount) * Quantity) AS Price FROM [Order Details]

	   JOIN Orders ON Orders.OrderID = [Order Details].OrderID
	   WHERE YEAR(Orders.OrderDate)= @Year
	   GROUP BY Orders.EmployeeID
ORDER BY Price DESC
END

/* 13.2	�������� ���������, ������� ���������� ������ � ������� Orders, �������� ���������� ����� �������� � ���� (������� ����� OrderDate � ShippedDate).  
		� ����������� ������ ���� ���������� ������, ���� ������� ��������� ���������� �������� ��� ��� �������������� ������. �������� �� ��������� ��� ������������� ����� 35 ����. 
		�������� ��������� ShippedOrdersDiff. ��������� ������ ����������� ��������� �������: OrderID, OrderDate, ShippedDate, ShippedDelay (�������� � ���� ����� ShippedDate � OrderDate), SpecifiedDelay (���������� � ��������� ��������).  
		���������� ������������������ ������������� ���� ���������. */
GO
CREATE PROCEDURE ShippedOrdersDiff
	@Difference INT = 35
AS BEGIN
	SELECT * FROM(SELECT OrderID, OrderDate, ShippedDate, DATEDIFF(day, OrderDate, ShippedDate) AS ShippedDelay, @Difference AS SpecifiedDelay FROM Orders) AS temp
	WHERE temp.ShippedDelay > @Difference OR ShippedDate IS NULL
END

/* 13.3	�������� ���������, ������� ����������� ���� ����������� ��������� ��������, ��� ����������������, ��� � ����������� ��� �����������. 
		� �������� �������� ��������� ������� ������������ EmployeeID. 
		���������� ����������� ����� ����������� � ��������� �� � ������ (������������ �������� PRINT) �������� �������� ����������. 
		��������, ��� �������� ���� ����� ����������� ����� ������ ���� ��������. �������� ��������� SubordinationInfo. 
		� �������� ��������� ��� ������� ���� ������ ���� ������������ ������, ����������� � Books Online � ��������������� Microsoft ��� ������� ��������� ���� �����. 
		������������������ ������������� ���������. */

GO
CREATE PROCEDURE SubordinationInfo
@EmployeeID INT
AS
BEGIN
	WITH Parent AS (SELECT EmployeeID
					FROM Employees
					WHERE EmployeeID = @EmployeeID),
		 Tree AS (SELECT x.EmployeeID, x.LastName, x.ReportsTo, 1 AS LevelUser
				  FROM Employees AS x
				  JOIN parent ON x.ReportsTo = parent.EmployeeID
				  UNION ALL
				  SELECT y.EmployeeID, y.LastName, y.ReportsTo, t.LevelUser + 1
				  FROM Employees AS y
				  JOIN tree t ON y.ReportsTo = t.EmployeeID)

	SELECT * FROM tree
END

GO
CREATE PROCEDURE SubordinationInfo_Print
@EmployeeID INT
AS
BEGIN
	DECLARE
	@xmltmp xml,
	@EmpID INT,
	@LastName NVARCHAR(50),
	@ReportsTo INT,
	@LevelUser INT,
	@LastNameBoss NVARCHAR(50);
	
	CREATE TABLE #EmpTree(EmployeeID INT, LastName NVARCHAR(50), ReportsTo INT, LevelUser INT);
	
	INSERT INTO #EmpTree
	EXECUTE SubordinationInfo @EmployeeID

	DECLARE my_cur CURSOR FOR 
	SELECT * FROM #EmpTree
	SET @LastNameBoss = (SELECT LastName FROM Employees WHERE @EmployeeID = EmployeeID)

	PRINT 'BOSS NODE -> ' + 
			  'EmployeeID - ' + Convert(NVARCHAR(MAX), @EmployeeID) + ', ' + 
			  'LastName - ' + @LastNameBoss

	OPEN my_cur
	FETCH NEXT FROM my_cur INTO @EmpID, @LastName, @ReportsTo, @LevelUser

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT SPACE(@LevelUser * 3) + 
			  'EmployeeID - ' + Convert(NVARCHAR(MAX), @EmpID) + ', ' + 
			  'LastName - ' + @LastName + ', ' +  
			  'ReportsTo - ' + Convert(NVARCHAR(MAX), @ReportsTo) + ', ' +  
			  'LevelUser - ' + Convert(NVARCHAR(MAX), @LevelUser)
		FETCH NEXT FROM my_cur INTO @EmpID, @LastName, @ReportsTo, @LevelUser
	END

	CLOSE my_cur
	DEALLOCATE my_cur

	DROP TABLE #EmpTree
END


/* 13.4 �������� �������, ������� ����������, ���� �� � �������� �����������. ���������� ��� ������ BIT. 
        � �������� �������� ��������� ������� ������������ EmployeeID. �������� ������� IsBoss. 
		������������������ ������������� ������� ��� ���� ��������� �� ������� Employees. */
GO
CREATE FUNCTION [dbo].[IsBoss](@EmployeeID INT)
RETURNS BIT
AS
BEGIN
	IF((SELECT COUNT(Employees.EmployeeID) FROM Employees
	JOIN (SELECT EmployeeID FROM Employees
	WHERE Employees.ReportsTo = @EmployeeID) AS Emp ON Employees.EmployeeID = Emp.EmployeeID) = 0)
	return 0
return 1
END