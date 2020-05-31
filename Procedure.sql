USE [Northwind]

/* 13.1	Написать процедуру, которая возвращает самый крупный заказ для каждого из продавцов за определенный год. 
		В результатах не может быть несколько заказов одного продавца, должен быть только один и самый крупный. 
		В результатах запроса должны быть выведены следующие колонки: колонка с именем и фамилией продавца (FirstName и LastName – пример: Nancy Davolio), номер заказа и его стоимость. 
		В запросе надо учитывать Discount при продаже товаров. 
		Процедуре передается год, за который надо сделать отчет, и количество возвращаемых записей. 
		Результаты запроса должны быть упорядочены по убыванию суммы заказа. 
		Процедура должна быть реализована с использованием оператора SELECT и БЕЗ ИСПОЛЬЗОВАНИЯ КУРСОРОВ. 
		Название функции соответственно GreatestOrders. Необходимо продемонстрировать использование этих процедур. 
		Также помимо демонстрации вызовов процедур в скрипте Query.sql надо написать отдельный ДОПОЛНИТЕЛЬНЫЙ проверочный запрос для тестирования правильности работы процедуры GreatestOrders. Проверочный запрос должен выводить в удобном для сравнения с результатами работы процедур виде для определенного продавца для всех его заказов за определенный указанный год в результатах следующие колонки: имя продавца, номер заказа, сумму заказа. Проверочный запрос не должен повторять запрос, написанный в процедуре, - он должен выполнять только то, что описано в требованиях по нему.
		ВСЕ ЗАПРОСЫ ПО ВЫЗОВУ ПРОЦЕДУР ДОЛЖНЫ БЫТЬ НАПИСАНЫ В ФАЙЛЕ Query.sql – см. пояснение ниже в разделе «Требования к оформлению».*/
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

/* 13.2	Написать процедуру, которая возвращает заказы в таблице Orders, согласно указанному сроку доставки в днях (разница между OrderDate и ShippedDate).  
		В результатах должны быть возвращены заказы, срок которых превышает переданное значение или еще недоставленные заказы. Значению по умолчанию для передаваемого срока 35 дней. 
		Название процедуры ShippedOrdersDiff. Процедура должна высвечивать следующие колонки: OrderID, OrderDate, ShippedDate, ShippedDelay (разность в днях между ShippedDate и OrderDate), SpecifiedDelay (переданное в процедуру значение).  
		Необходимо продемонстрировать использование этой процедуры. */
GO
CREATE PROCEDURE ShippedOrdersDiff
	@Difference INT = 35
AS BEGIN
	SELECT * FROM(SELECT OrderID, OrderDate, ShippedDate, DATEDIFF(day, OrderDate, ShippedDate) AS ShippedDelay, @Difference AS SpecifiedDelay FROM Orders) AS temp
	WHERE temp.ShippedDelay > @Difference OR ShippedDate IS NULL
END

/* 13.3	Написать процедуру, которая высвечивает всех подчиненных заданного продавца, как непосредственных, так и подчиненных его подчиненных. 
		В качестве входного параметра функции используется EmployeeID. 
		Необходимо распечатать имена подчиненных и выровнять их в тексте (использовать оператор PRINT) согласно иерархии подчинения. 
		Продавец, для которого надо найти подчиненных также должен быть высвечен. Название процедуры SubordinationInfo. 
		В качестве алгоритма для решения этой задачи надо использовать пример, приведенный в Books Online и рекомендованный Microsoft для решения подобного типа задач. 
		Продемонстрировать использование процедуры. */

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


/* 13.4 Написать функцию, которая определяет, есть ли у продавца подчиненные. Возвращает тип данных BIT. 
        В качестве входного параметра функции используется EmployeeID. Название функции IsBoss. 
		Продемонстрировать использование функции для всех продавцов из таблицы Employees. */
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