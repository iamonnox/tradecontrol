/*****************************************
SCALAR FUNCTIONS
*****************************************/
--Dependent objects
CREATE FUNCTION App.fnAdjustDateToBucket
	(
	@BucketDay SMALLINT,
	@CurrentDate DATETIME
	)
RETURNS DATETIME
  AS
	BEGIN
	DECLARE @CurrentDay SMALLINT
	DECLARE @Offset SMALLINT
	DECLARE @AdjustedDay SMALLINT
	
	SET @CurrentDay = DATEPART(dw, @CurrentDate)
	
	SET @AdjustedDay = CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END

	SET @Offset = CASE WHEN @BucketDay <= @AdjustedDay THEN
				@BucketDay - @AdjustedDay
			ELSE
				(7 - (@BucketDay - @AdjustedDay)) * -1
			END
	
		
	RETURN DATEADD(dd, @Offset, @CurrentDate)
	END
GO
CREATE FUNCTION App.fnBuckets
	(@CurrentDate DATETIME)
RETURNS  @tbBkn TABLE ([Period] SMALLINT, BucketId NVARCHAR(10), StartDate DATETIME, EndDate DATETIME)
  AS
	BEGIN
	DECLARE @BucketTypeCode SMALLINT
	DECLARE @UnitOfTimeCode SMALLINT
	DECLARE @Period SMALLINT	
	DECLARE @CurrentPeriod SMALLINT
	DECLARE @Offset SMALLINT
	
	DECLARE @StartDate DATETIME
	DECLARE @EndDate DATETIME
	DECLARE @BucketId NVARCHAR(10)
		
	SELECT     TOP 1 @BucketTypeCode = BucketTypeCode, @UnitOfTimeCode = BucketIntervalCode
	FROM         App.tbOptions
		
	SET @EndDate = 
		CASE @BucketTypeCode
			WHEN 0 THEN
				@CurrentDate
			WHEN 8 THEN
				DATEADD(d, DAY(@CurrentDate) * -1 + 1, @CurrentDate)
			ELSE
				App.fnAdjustDateToBucket(@BucketTypeCode, @CurrentDate)
		END
			
	SET @EndDate = CAST(@EndDate AS DATE) 
	SET @StartDate = DATEADD(yyyy, -100, @EndDate)
	SET @CurrentPeriod = 0
	
	DECLARE curBk CURSOR FOR			
		SELECT     Period, BucketId
		FROM         App.tbBucket
		ORDER BY Period

	OPEN curBk
	FETCH NEXT FROM curBk INTO @Period, @BucketId
	WHILE @@FETCH_STATUS = 0
		BEGIN
		IF @Period > 0
			BEGIN
			SET @StartDate = @EndDate
			SET @Offset = @Period - @CurrentPeriod
			SET @EndDate = CASE @UnitOfTimeCode
				WHEN 1 THEN		--day
					DATEADD(d, @Offset, @StartDate) 					
				WHEN 2 THEN		--week
					DATEADD(d, @Offset * 7, @StartDate)
				WHEN 3 THEN		--month
					DATEADD(m, @Offset, @StartDate)
				END
			END
		
		INSERT INTO @tbBkn(Period, BucketId, StartDate, EndDate)
		VALUES (@Period, @BucketId, @StartDate, @EndDate)
		
		SET @CurrentPeriod = @Period
		
		FETCH NEXT FROM curBk INTO @Period, @BucketId
		END
		
			
	RETURN
	END
GO

CREATE VIEW App.vwCorpTaxCashCode
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 1)
GO
ALTER AUTHORIZATION ON App.vwCorpTaxCashCode TO  SCHEMA OWNER 
GO
CREATE FUNCTION App.fnAccountPeriod
	(
	@TransactedOn DATETIME
	)
RETURNS DATETIME
 AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT TOP 1 @StartOn = StartOn
	FROM         App.tbYearPeriod
	WHERE     (StartOn <= @TransactedOn)
	ORDER BY StartOn DESC
	
	RETURN @StartOn
	END
GO
CREATE FUNCTION Cash.fnCategoryCashCodes
	(
	@CategoryCode NVARCHAR(10)
	)
RETURNS @tbCashCode TABLE (CashCode NVARCHAR(50))
  AS
	BEGIN
	INSERT INTO @tbCashCode (CashCode)
	SELECT     Cash.tbCode.CashCode
	FROM         Cash.tbCategoryTotal INNER JOIN
	                      Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode INNER JOIN
	                      Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	WHERE     ( Cash.tbCategoryTotal.ParentCode = @CategoryCode)
	
	DECLARE @ChildCode NVARCHAR(10)
	
	DECLARE curCat CURSOR LOCAL FOR
		SELECT     Cash.tbCategory.CategoryCode
		FROM         Cash.tbCategory INNER JOIN
		                      Cash.tbCategoryTotal ON Cash.tbCategory.CategoryCode = Cash.tbCategoryTotal.ChildCode
		WHERE     ( Cash.tbCategory.CategoryTypeCode = 2) AND ( Cash.tbCategoryTotal.ParentCode = @CategoryCode)
	
	OPEN curCat
	FETCH NEXT FROM curCat INTO @ChildCode
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbCashCode(CashCode)
		SELECT CashCode FROM Cash.fnCategoryCashCodes(@ChildCode)
		FETCH NEXT FROM curCat INTO @ChildCode
		END
	
	CLOSE curCat
	DEALLOCATE curCat
	
	RETURN
	END
GO
CREATE FUNCTION Cash.fnCorpTaxCashCodes
	()
RETURNS @tbCashCode TABLE (CashCode NVARCHAR(50))
  AS
	BEGIN
	DECLARE @CategoryCode NVARCHAR(10)
	SELECT @CategoryCode = NetProfitCode FROM App.tbOptions	
	SET @CategoryCode = ISNULL(@CategoryCode, '')
	IF (@CategoryCode != '')
		BEGIN
		INSERT INTO @tbCashCode (CashCode)
		SELECT CashCode FROM Cash.fnCategoryCashCodes(@CategoryCode)
		END
	RETURN
	END
GO

CREATE VIEW Cash.vwCorpTaxInvoiceItems
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
FROM         Invoice.tbItem INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY StartOn

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxInvoiceItems TO  SCHEMA OWNER 
GO

GO

GO
CREATE VIEW Cash.vwCorpTaxInvoiceTasks
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
FROM         Invoice.tbTask INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY StartOn

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxInvoiceTasks TO  SCHEMA OWNER 
GO

GO

GO
CREATE VIEW Cash.vwCorpTaxInvoiceValue
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxInvoiceValue TO  SCHEMA OWNER 
GO

GO

GO
CREATE VIEW Cash.vwCorpTaxInvoiceBase
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceValue
GROUP BY StartOn

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxInvoiceBase TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCorpTaxInvoice
AS
SELECT     TOP (100) PERCENT App.tbYearPeriod.StartOn, Cash.vwCorpTaxInvoiceBase.NetProfit, 
                      Cash.vwCorpTaxInvoiceBase.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
                      App.tbYearPeriod.TaxAdjustment
FROM         Cash.vwCorpTaxInvoiceBase INNER JOIN
                      App.tbYearPeriod ON Cash.vwCorpTaxInvoiceBase.StartOn = App.tbYearPeriod.StartOn
ORDER BY App.tbYearPeriod.StartOn

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxInvoice TO  SCHEMA OWNER 
GO

CREATE VIEW Invoice.vwVatItems
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Org.tbOrg.ForeignJurisdiction, 
                      Invoice.tbItem.CashCode AS IdentityCode
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
WHERE     (App.tbTaxCode.TaxTypeCode = 2)
ORDER BY StartOn
GO
ALTER AUTHORIZATION ON Invoice.vwVatItems TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwVatTasks
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, Org.tbOrg.ForeignJurisdiction, 
                      Invoice.tbTask.TaskCode AS IdentityCode
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
WHERE     (App.tbTaxCode.TaxTypeCode = 2)
ORDER BY StartOn

GO
ALTER AUTHORIZATION ON Invoice.vwVatTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwVatBase
AS
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         Invoice.vwVatItems
UNION
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         Invoice.vwVatTasks

GO
ALTER AUTHORIZATION ON Invoice.vwVatBase TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwVatDetail
AS
SELECT        StartOn, TaxCode, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 1 THEN InvoiceValue WHEN 2 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 3 THEN InvoiceValue WHEN 4 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 1 THEN InvoiceValue WHEN 2 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 3 THEN InvoiceValue WHEN 4 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 1 THEN TaxValue WHEN 2 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 3 THEN TaxValue WHEN 4 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 1 THEN TaxValue WHEN 2 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 3 THEN TaxValue WHEN 4 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
FROM            Invoice.vwVatBase

GO
ALTER AUTHORIZATION ON Invoice.vwVatDetail TO  SCHEMA OWNER 
GO

CREATE VIEW Invoice.vwVatSummary
AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         Invoice.vwVatDetail
GROUP BY StartOn, TaxCode

GO
ALTER AUTHORIZATION ON Invoice.vwVatSummary TO  SCHEMA OWNER 
GO

CREATE FUNCTION App.fnActivePeriod
	(
	)
RETURNS @tbSystemYearPeriod TABLE (YearNumber SMALLINT, StartOn DATETIME, EndOn DATETIME, MonthName NVARCHAR(10), Description NVARCHAR(10), MonthNumber SMALLINT) 
   AS
	BEGIN
	DECLARE @StartOn DATETIME
	DECLARE @EndOn DATETIME
	
	IF exists (	SELECT     StartOn	FROM App.tbYearPeriod WHERE (CashStatusCode < 3))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (CashStatusCode < 3)
		
		IF exists (SELECT StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn)
			SELECT top 1 @EndOn = StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn ORDER BY StartOn
		ELSE
			SET @EndOn = DATEADD(m, 1, @StartOn)
			
		INSERT INTO @tbSystemYearPeriod (YearNumber, StartOn, EndOn, MonthName, Description, MonthNumber)
		SELECT     App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, @EndOn, App.tbMonth.[MonthName], App.tbYear.[Description], App.tbMonth.MonthNumber
		FROM         App.tbYearPeriod INNER JOIN
		                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
		                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE     ( App.tbYearPeriod.StartOn = @StartOn)
		END	
	RETURN
	END
GO
CREATE VIEW Task.vwCashMode
  AS
SELECT     Task.tbTask.TaskCode, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                      THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
GO
ALTER AUTHORIZATION ON Task.vwCashMode TO  SCHEMA OWNER 
GO
CREATE FUNCTION Task.fnProfitCost
	(
	@ParentTaskCode NVARCHAR(20),
	@TotalCost MONEY,
	@InvoicedCost MONEY,
	@InvoicedCostPaid MONEY
	)
RETURNS @tbCost TABLE (	
	TotalCost MONEY,
	InvoicedCost MONEY,
	InvoicedCostPaid MONEY
	)
AS
	BEGIN
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TotalCharge MONEY
DECLARE @TotalInvoiced MONEY
DECLARE @TotalPaid MONEY
DECLARE @CashModeCode SMALLINT

	DECLARE curFlow CURSOR LOCAL FOR
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)  AND ( Task.tbTask.TaskStatusCode < 5)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue ELSE Invoice.tbTask.InvoiceValue * - 1 END), 
				@TotalPaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.PaidValue ELSE Invoice.tbTask.PaidValue * - 1 END) 	                      
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)

		SET @InvoicedCost = @InvoicedCost + ISNULL(@TotalInvoiced, 0)
		SET @InvoicedCostPaid = @InvoicedCostPaid + ISNULL(@TotalPaid, 0)
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 1 THEN @TotalCharge ELSE @TotalCharge * -1 END
		
		SELECT @TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM         Task.fnProfitCost(@TaskCode, @TotalCost, @InvoicedCost, @InvoicedCostPaid) AS fnTaskProfitCost_1	
		
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow

	INSERT INTO @tbCost (TotalCost, InvoicedCost, InvoicedCostPaid)
	VALUES (@TotalCost, @InvoicedCost, @InvoicedCostPaid)		
	
	
	RETURN
	END

GO

CREATE FUNCTION Task.fnProfitOrder
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS @tbOrder TABLE (	
	InvoicedCharge MONEY,
	InvoicedChargePaid MONEY,
	TotalCost MONEY,
	InvoicedCost MONEY,
	InvoicedCostPaid MONEY
	)
AS
	BEGIN
DECLARE @InvoicedCharge MONEY
DECLARE @InvoicedChargePaid MONEY
DECLARE @TotalCost MONEY
DECLARE @InvoicedCost MONEY
DECLARE @InvoicedCostPaid MONEY

	SELECT  @InvoicedCharge = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)
	
	SELECT TOP 1 @TotalCost = TotalCost, @InvoicedCost = InvoicedCost, @InvoicedCostPaid = InvoicedCostPaid
	FROM         Task.fnProfitCost(@TaskCode, 0, 0, 0) AS fnTaskProfitCost_1
	
	INSERT INTO @tbOrder (InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		VALUES (ISNULL(@InvoicedCharge, 0), ISNULL(@InvoicedChargePaid, 0), @TotalCost, @InvoicedCost, @InvoicedCostPaid)
	
	RETURN
	END

GO
CREATE FUNCTION App.fnHistoryStartOn()
RETURNS DATETIME
AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT  @StartOn = MIN( App.tbYearPeriod.StartOn)
	FROM            App.tbYear INNER JOIN
	                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber
	WHERE        ( App.tbYear.CashStatusCode < 4)
	
	RETURN @StartOn
	END

GO

CREATE VIEW Task.vwProfitOrders
AS
SELECT     App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, Task.tbTask.TaskCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN Task.tbTask.TotalCharge * - 1 ELSE Task.tbTask.TotalCharge END AS TotalCharge
FROM         Cash.tbCode INNER JOIN
                      Task.tbTask ON Cash.tbCode.CashCode = Task.tbTask.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.tbTask AS Task_tb1 RIGHT OUTER JOIN
                      Task.tbFlow ON Task_tb1.TaskCode = Task.tbFlow.ParentTaskCode ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode
WHERE     (Task.tbTask.TaskStatusCode > 1) AND (Task.tbFlow.ParentTaskCode IS NULL) AND ( Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 5) AND 
                      (Task.tbTask.ActionOn >= App.fnHistoryStartOn()) OR
                      (Task.tbTask.TaskStatusCode > 1) AND ( Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 5) AND (Task.tbTask.ActionOn >= App.fnHistoryStartOn())

GO
ALTER AUTHORIZATION ON Task.vwProfitOrders TO  SCHEMA OWNER 
GO
CREATE FUNCTION Task.fnProfit()
RETURNS @tbTaskProfit TABLE (
	TaskCode NVARCHAR(20),
	StartOn DATETIME,
	TotalCharge MONEY,
	InvoicedCharge MONEY,
	InvoicedChargePaid MONEY,
	TotalCost MONEY,
	InvoicedCost MONEY,
	InvoicedCostPaid MONEY
	) 
AS
	BEGIN
DECLARE @StartOn DATETIME
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TotalCharge MONEY
DECLARE @InvoicedCharge MONEY
DECLARE @InvoicedChargePaid MONEY
DECLARE @TotalCost MONEY
DECLARE @InvoicedCost MONEY
DECLARE @InvoicedCostPaid MONEY


	DECLARE curTasks CURSOR LOCAL FOR
		SELECT     StartOn, TaskCode, TotalCharge
		FROM         Task.vwProfitOrders
		ORDER BY StartOn

	OPEN curTasks
	FETCH NEXT FROM curTasks INTO @StartOn, @TaskCode, @TotalCharge
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @InvoicedCharge = 0
		SET @InvoicedChargePaid = 0
		SET @TotalCost = 0
		SET @InvoicedCost = 0
		SET @InvoicedCostPaid = 0
				
		SELECT   @InvoicedCharge = InvoicedCharge, 
			@InvoicedChargePaid = InvoicedChargePaid, 
			@TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM   Task.fnProfitOrder(@TaskCode) AS fnTaskProfitOrder_1
		
		INSERT INTO @tbTaskProfit (TaskCode, StartOn, TotalCharge, InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		VALUES (@TaskCode, @StartOn, @TotalCharge, @InvoicedCharge, @InvoicedChargePaid, @TotalCost, @InvoicedCost, @InvoicedCostPaid)
		
		FETCH NEXT FROM curTasks INTO @StartOn, @TaskCode, @TotalCharge	
		END
	
	CLOSE curTasks
	DEALLOCATE curTasks
		
	RETURN
	END
GO
CREATE VIEW Task.vwProfit
AS
SELECT     TOP (100) PERCENT fnTaskProfit_1.StartOn, Org.tbOrg.AccountCode, Task.tbTask.TaskCode, App.tbYearPeriod.YearNumber, App.tbYear.[Description], 
                      CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Task.tbTask.ActivityCode, Cash.tbCode.CashCode, 
                      Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Cash.tbCode.CashDescription, Task.tbStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, fnTaskProfit_1.InvoicedCostPaid, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn
FROM         Task.tbTask INNER JOIN
                      Task.fnProfit() AS fnTaskProfit_1 ON Task.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.tbYearPeriod ON fnTaskProfit_1.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Cash.tbCategory.CashModeCode = 2)
ORDER BY fnTaskProfit_1.StartOn

GO
ALTER AUTHORIZATION ON Task.vwProfit TO  SCHEMA OWNER 
GO

--Scalar Functions
CREATE FUNCTION App.fnWeekDay
	(
	@Date DATETIME
	)
RETURNS SMALLINT
    AS
	BEGIN
	DECLARE @CurrentDay SMALLINT
	SET @CurrentDay = DATEPART(dw, @Date)
	RETURN 	CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END
	END
GO

CREATE FUNCTION App.fnAdjustToCalendar
	(
	@UserId NVARCHAR(10),
	@SourceDate DATETIME,
	@Days int
	)
RETURNS DATETIME
    AS
	BEGIN
	DECLARE @CalendarCode NVARCHAR(10)
	DECLARE @TargetDate DATETIME
	DECLARE @WorkingDay bit
	
	DECLARE @CurrentDay SMALLINT
	DECLARE @Monday SMALLINT
	DECLARE @Tuesday SMALLINT
	DECLARE @Wednesday SMALLINT
	DECLARE @Thursday SMALLINT
	DECLARE @Friday SMALLINT
	DECLARE @Saturday SMALLINT
	DECLARE @Sunday SMALLINT
		
	SET @TargetDate = @SourceDate

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
	                      Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = @UserId
	
	WHILE @Days > -1
		BEGIN
		SET @CurrentDay = App.fnWeekDay(@TargetDate)
		IF @CurrentDay = 1				
			SET @WorkingDay = CASE WHEN @Monday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 2
			SET @WorkingDay = CASE WHEN @Tuesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 3
			SET @WorkingDay = CASE WHEN @Wednesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 4
			SET @WorkingDay = CASE WHEN @Thursday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 5
			SET @WorkingDay = CASE WHEN @Friday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 6
			SET @WorkingDay = CASE WHEN @Saturday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 7
			SET @WorkingDay = CASE WHEN @Sunday != 0 THEN 1 ELSE 0 END
		
		IF @WorkingDay = 1
			BEGIN
			IF not exists(SELECT     UnavailableOn
				        FROM         App.tbCalendarHoliday
				        WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @TargetDate))
				SET @Days = @Days - 1
			END
			
		IF @Days > -1
			SET @TargetDate = DATEADD(d, -1, @TargetDate)
		END
		

	RETURN @TargetDate
	END
GO

CREATE FUNCTION App.fnCompanyAccount()
RETURNS NVARCHAR(10)
AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	SELECT @AccountCode = AccountCode FROM App.tbOptions
	RETURN @AccountCode
	END

GO
CREATE FUNCTION Cash.fnCurrentBalance
	()
RETURNS MONEY
AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT    @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount INNER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION App.fnDocTaskType
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	DECLARE @TaskStatusCode SMALLINT
	DECLARE @CashModeCode SMALLINT
	
	SELECT    @CashModeCode = Cash.tbCategory.CashModeCode, @TaskStatusCode = Task.tbTask.TaskStatusCode
	FROM            Task.tbTask INNER JOIN
	                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE TaskCode = @TaskCode
	
	SET @DocTypeCode = CASE 
		WHEN @CashModeCode = 1 THEN						--Expense
			CASE WHEN @TaskStatusCode = 1 THEN 3		--Enquiry
				ELSE 4 END			
		WHEN @CashModeCode = 2 THEN						--Income
			CASE WHEN @TaskStatusCode = 1 THEN 1		--Quote
				ELSE 2 END
		END
				
	RETURN @DocTypeCode
	END

GO
CREATE FUNCTION App.fnDocInvoiceType
	(
	@InvoiceTypeCode SMALLINT
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
		WHEN 1 THEN 5		--sales invoice
		WHEN 2 THEN 6		--credit note
		WHEN 4 THEN 7		--debit note
		ELSE 8				--error
		END
	
	RETURN @DocTypeCode
	END

GO
CREATE FUNCTION App.fnTaxHorizon	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM App.tbOptions
	RETURN @TaxHorizon
	END

GO
CREATE FUNCTION Cash.fnReserveBalance
	()
RETURNS MONEY
AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT    @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount LEFT OUTER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0) AND ( Cash.tbCode.CashCode IS NULL)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION Task.fnIsExpense
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS bit
AS
	BEGIN
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     Task.tbTask.TaskCode
	           FROM         Task.tbTask INNER JOIN
	                                 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                                 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	           WHERE     ( Cash.tbCategory.CashModeCode = 2) AND ( Task.tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         Task.tbFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode NVARCHAR(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         Task.tbFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = Task.fnIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END

GO
CREATE FUNCTION Task.fnDefaultPaymentOn
	(
		@AccountCode NVARCHAR(10),
		@ActionOn DATETIME
	)
RETURNS DATETIME
AS
	BEGIN
	DECLARE @PaymentOn DATETIME
	DECLARE @PaymentDays SMALLINT
	DECLARE @UserId NVARCHAR(10)
	DECLARE @PayDaysFromMonthEnd bit
	
	SELECT @UserId =  UserId
	FROM         Usr.tbUser
	WHERE     (LogonName = SUSER_SNAME())

	SELECT @PaymentDays = PaymentDays, @PayDaysFromMonthEnd = PayDaysFromMonthEnd
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	IF (@PayDaysFromMonthEnd <> 0)
		SET @PaymentOn = DATEADD(d, @PaymentDays, DATEADD(d, ((day(@ActionOn) - 1) + 1) * -1, DATEADD(m, 1, @ActionOn)))
	ELSE
		SET @PaymentOn = DATEADD(d, @PaymentDays, @ActionOn)
		
	SET @PaymentOn = App.fnAdjustToCalendar(@UserId, @PaymentOn, 0)	
	
	
	RETURN @PaymentOn
	END

GO
CREATE FUNCTION Task.fnEmailAddress
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS NVARCHAR(255)
AS
	BEGIN
	DECLARE @EmailAddress NVARCHAR(255)

	IF exists(SELECT     Org.tbContact.EmailAddress
		  FROM         Org.tbContact INNER JOIN
								tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
		  WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		  GROUP BY Org.tbContact.EmailAddress
		  HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL)))
		BEGIN
		SELECT    @EmailAddress = Org.tbContact.EmailAddress
		FROM         Org.tbContact INNER JOIN
							tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		GROUP BY Org.tbContact.EmailAddress
		HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL))	
		END
	ELSE
		BEGIN
		SELECT    @EmailAddress =  Org.tbOrg.EmailAddress
		FROM         Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		END
	
	RETURN @EmailAddress
	END

GO
CREATE FUNCTION Task.fnCost
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS MONEY
AS
	BEGIN
	
	DECLARE @ChildTaskCode NVARCHAR(20)
	DECLARE @TotalCharge MONEY
	DECLARE @TotalCost MONEY
	DECLARE @CashModeCode SMALLINT

	DECLARE curFlow CURSOR LOCAL FOR
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @ChildTaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 1 THEN @TotalCharge ELSE @TotalCharge * -1 END
		SET @TotalCost = @TotalCost + Task.fnCost(@ChildTaskCode)
		FETCH NEXT FROM curFlow INTO @ChildTaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	RETURN @TotalCost
	END

GO
CREATE FUNCTION Cash.fnCodeDefaultAccount 
	(
	@CashCode NVARCHAR(50)
	)
RETURNS NVARCHAR(10)
 AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	IF exists(SELECT     CashCode
	          FROM         Invoice.tbTask
	          WHERE     (CashCode = @CashCode))
		BEGIN
		SELECT  @AccountCode = Invoice.tbInvoice.AccountCode
		FROM         Invoice.tbTask INNER JOIN
		                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbTask.CashCode = @CashCode)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC		
		END
	ELSE IF exists(SELECT     CashCode
	          FROM         Invoice.tbItem
	          WHERE     (CashCode = @CashCode))
		BEGIN
		SELECT  @AccountCode = Invoice.tbInvoice.AccountCode
		FROM         Invoice.tbItem INNER JOIN
		                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbItem.CashCode = @CashCode)		
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC	
		END
	ELSE
		BEGIN	
		SELECT @AccountCode = AccountCode FROM App.tbOptions
		END
		
	RETURN @AccountCode
	END

GO
CREATE FUNCTION Task.fnDefaultTaxCode 
	(
	@AccountCode NVARCHAR(10),
	@CashCode NVARCHAR(50)
	)
RETURNS NVARCHAR(10)
  AS
	BEGIN
	DECLARE @TaxCode NVARCHAR(10)
	
	IF (not @AccountCode is null) and (not @CashCode is null)
		BEGIN
		IF exists(SELECT     TaxCode
			  FROM         Org.tbOrg
			  WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL)))
			BEGIN
			SELECT    @TaxCode = TaxCode
			FROM         Org.tbOrg
			WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL))
			END
		ELSE
			BEGIN
			SELECT    @TaxCode =  TaxCode
			FROM         Cash.tbCode
			WHERE     (CashCode = @CashCode)		
			END
		END
	ELSE
		SET @TaxCode = null
				
	RETURN @TaxCode
	END
GO

CREATE  FUNCTION App.fnVatBalance
	()
RETURNS MONEY
  AS
	BEGIN
	DECLARE @Balance MONEY
	SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
	FROM         Invoice.vwVatSummary
	
	SELECT  @Balance = @Balance + ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	                      

	SELECT @Balance = @Balance + SUM(VatAdjustment)
	FROM App.tbYearPeriod

	RETURN ISNULL(@Balance, 0)
	END
GO
CREATE FUNCTION App.fnProfileText
	(
	@TextId int
	)
RETURNS NVARCHAR(255)
  AS
	BEGIN
	DECLARE @Message NVARCHAR(255)
	SELECT top 1 @Message = Message FROM App.tbText
	WHERE TextId = @TextId
	RETURN @Message
	END
GO
CREATE FUNCTION App.fnDateBucket
	(@CurrentDate DATETIME, @BucketDate DATETIME)
RETURNS SMALLINT
  AS
	BEGIN
	DECLARE @Period SMALLINT
	SELECT  @Period = Period
	FROM         App.fnBuckets(@CurrentDate) fnEnvBuckets
	WHERE     (StartDate <= @BucketDate) AND (EndDate > @BucketDate) 
	RETURN @Period
	END
GO
CREATE FUNCTION App.fnCorpTaxBalance
	()
RETURNS MONEY
  AS
	BEGIN
	DECLARE @Balance MONEY
	SELECT  @Balance = SUM(CorporationTax)
	FROM         Cash.vwCorpTaxInvoice
	
	SELECT  @Balance = @Balance + ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwCorpTaxCashCode ON Org.tbPayment.CashCode = App.vwCorpTaxCashCode.CashCode	                      

	IF @Balance < 0
		SET @Balance = 0
		
	RETURN ISNULL(@Balance, 0)
	END
GO
CREATE  FUNCTION App.fnCashCode
	(
	@TaxTypeCode SMALLINT
	)
RETURNS NVARCHAR(50)
  AS
	BEGIN
	DECLARE @CashCode NVARCHAR(50)
	
	SELECT @CashCode = CashCode
	FROM         Cash.tbTaxType
	WHERE     (TaxTypeCode = @TaxTypeCode)
		
	
	RETURN @CashCode
	END
GO
CREATE FUNCTION App.fnActiveStartOn
	()
RETURNS DATETIME
  AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT @StartOn = StartOn FROM App.fnActivePeriod()
	RETURN @StartOn
	END
GO
CREATE FUNCTION Org.fnStatementTaxAccount
	(
	@TaxTypeCode SMALLINT
	)
RETURNS NVARCHAR(10)
  AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	IF exists (SELECT     AccountCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL)))
		BEGIN
		SELECT @AccountCode = AccountCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL))
		END
	ELSE
		BEGIN
		SELECT TOP 1 @AccountCode = AccountCode
		FROM         App.tbOptions		
		END
			
	
	RETURN @AccountCode
	END
GO
CREATE FUNCTION Org.fnIndustrySectors
	(
	@AccountCode NVARCHAR(10)
	)
RETURNS NVARCHAR(256)
  AS
	BEGIN
	DECLARE @IndustrySector NVARCHAR(256)
	
	IF exists(SELECT IndustrySector FROM Org.tbSector WHERE AccountCode = @AccountCode)
		BEGIN
		DECLARE @Sector NVARCHAR(50)
		SET @IndustrySector = ''
		DECLARE cur CURSOR LOCAL FOR
			SELECT IndustrySector FROM Org.tbSector WHERE AccountCode = @AccountCode
		OPEN cur
		FETCH NEXT FROM cur INTO @Sector
		WHILE @@FETCH_STATUS = 0
			BEGIN
			IF len(@IndustrySector) = 0
				SET @IndustrySector = @Sector
			ELSE IF len(@IndustrySector) <= 200
				SET @IndustrySector = @IndustrySector + ', ' + @Sector
			
			FETCH NEXT FROM cur INTO @Sector
			END
			
		CLOSE cur
		DEALLOCATE cur
		
		END	
	
	RETURN @IndustrySector
	END
GO
CREATE FUNCTION Cash.fnCompanyBalance()
RETURNS MONEY
  AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT  @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount 
	WHERE     ( Org.tbAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION App.fnParsePrimaryKey(@PK NVARCHAR(50)) RETURNS BIT
AS
	BEGIN
		DECLARE @ParseOk BIT = 0;

		SET @ParseOk = CASE		
				WHEN CHARINDEX('"', @PK) > 0 THEN 0	
				WHEN CHARINDEX('''', @PK) > 0 THEN 0	
				WHEN CHARINDEX(',', @PK) > 0 THEN 0	
				WHEN CHARINDEX('<', @PK) > 0 THEN 0	
				WHEN CHARINDEX('>', @PK) > 0 THEN 0	
				WHEN CHARINDEX('@', @PK) > 0 THEN 0	
				WHEN CHARINDEX(':', @PK) > 0 THEN 0	
				WHEN CHARINDEX('*', @PK) > 0 THEN 0	
				WHEN CHARINDEX('[', @PK) > 0 THEN 0	
				WHEN CHARINDEX(']', @PK) > 0 THEN 0	
				WHEN CHARINDEX('{', @PK) > 0 THEN 0	
				WHEN CHARINDEX('}', @PK) > 0 THEN 0	
				ELSE 1 END;

		RETURN @ParseOk;
	END
GO


