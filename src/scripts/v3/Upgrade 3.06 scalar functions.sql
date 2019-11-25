/********** SCALAR FUNCTION *****/
DROP FUNCTION IF EXISTS App.fnAdjustToCalendar;
DROP FUNCTION IF EXISTS Task.fnDefaultTaxCode; 
DROP FUNCTION IF EXISTS Task.fnDefaultPaymentOn;
DROP FUNCTION IF EXISTS Task.fnCost;
go

--App.fnAccountPeriod
ALTER VIEW Cash.vwCodeForecastSummary
AS
	WITH tasks AS
	(
	SELECT task.CashCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE StartOn <= task.ActionOn ORDER BY StartOn DESC) AS StartOn,
		task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
	FROM Task.tbTask task INNER JOIN
							 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Invoice.tbTask AS InvoiceTask ON task.TaskCode = InvoiceTask.TaskCode AND task.TaskCode = InvoiceTask.TaskCode LEFT OUTER JOIN
							 App.vwTaxRates tax ON task.TaxCode = tax.TaxCode
	)
	SELECT CashCode, StartOn, 
		SUM(TotalCharge) AS ForecastValue,
		SUM(TotalCharge * TaxRate) AS ForecastTax
	FROM tasks
	GROUP BY CashCode, StartOn;
go
ALTER VIEW Cash.vwCodeOrderSummary
AS
	WITH tasks AS
	(
		SELECT        task.CashCode,
									 (SELECT        TOP (1) StartOn
									   FROM            App.tbYearPeriod
									   WHERE        (StartOn <= task.ActionOn)
									   ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(invoice.InvoiceValue, 0) AS InvoiceValue, 
										ISNULL(invoice.InvoiceTax, 0) AS InvoiceTax, ISNULL(tax.TaxRate, 0) AS TaxRate
		FROM            Task.tbTask AS task INNER JOIN
								 Cash.tbCode AS cash ON task.CashCode = cash.CashCode LEFT OUTER JOIN
								 Task.vwInvoiceValue AS invoice ON task.TaskCode = invoice.TaskCode LEFT OUTER JOIN
								 App.vwTaxRates AS tax ON task.TaxCode = tax.TaxCode
		WHERE        (task.TaskStatusCode = 1) OR
								 (task.TaskStatusCode = 2)
	)
	SELECT CashCode, StartOn, 
		SUM(TotalCharge - InvoiceValue) AS InvoiceValue,
		SUM((TotalCharge * TaxRate)-InvoiceTax) AS InvoiceTax
	FROM tasks
	GROUP BY CashCode, StartOn;
go
ALTER VIEW Cash.vwCorpTaxConfirmedBase
AS
	SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Task.tbTask.PaymentOn) ORDER BY StartOn DESC) AS StartOn, 
				CASE WHEN Cash.tbCategory.CashModeCode = 0 
					THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) * - 1 
					ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
				END AS OrderValue
	FROM            Task.vwInvoicedQuantity RIGHT OUTER JOIN
							 Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
							 Cash.tbCategory INNER JOIN
							 Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.vwInvoicedQuantity.TaskCode = Task.tbTask.TaskCode
	WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0) AND (Task.tbTask.PaymentOn <=
								 (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) AS HorizonOn FROM App.tbOptions));
go
ALTER VIEW Cash.vwCorpTaxInvoiceItems
AS
	SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
						  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
	FROM         Invoice.tbItem INNER JOIN
						  Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
						  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
						  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode;
go
ALTER VIEW Cash.vwCorpTaxInvoiceTasks
AS
	SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
	FROM            Invoice.tbTask INNER JOIN
							 Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode;
go
ALTER VIEW Cash.vwCorpTaxTasksBase
AS
	SELECT Task.tbTask.TaskCode, Task.tbStatus.TaskStatus, 
		(SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.PaymentOn) ORDER BY p.StartOn DESC) AS StartOn,
							 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
							 * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
	FROM            Task.tbStatus INNER JOIN
							 Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
							 Cash.tbCategory INNER JOIN
							 Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
							 Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
	WHERE        (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0);
go
ALTER VIEW Task.vwProfitOrders
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.ActionOn) ORDER BY p.StartOn DESC) AS StartOn, Task.tbTask.TaskCode, 
							 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN Task.tbTask.TotalCharge * - 1 ELSE Task.tbTask.TotalCharge END AS TotalCharge
	FROM            Cash.tbCode INNER JOIN
							 Task.tbTask ON Cash.tbCode.CashCode = Task.tbTask.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
							 Task.tbTask AS Task_tb1 RIGHT OUTER JOIN
							 Task.tbFlow ON Task_tb1.TaskCode = Task.tbFlow.ParentTaskCode ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode
	WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbFlow.ParentTaskCode IS NULL) AND (Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 4) 
		AND (Task.tbTask.ActionOn >= (SELECT  MIN( App.tbYearPeriod.StartOn) FROM App.tbYear INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber	WHERE ( App.tbYear.CashStatusCode < 3))) 
			OR (Task.tbTask.TaskStatusCode > 0) AND (Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 4) 
				AND (Task.tbTask.ActionOn >= 
					(SELECT  MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
						INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
						WHERE ( App.tbYear.CashStatusCode < 3))
				);
go
ALTER VIEW Invoice.vwRegister
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
							 Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
	WHERE        (Invoice.tbInvoice.AccountCode <> (SELECT AccountCode FROM App.tbOptions));
go
ALTER VIEW Invoice.vwRegisterItems
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidValue * - 1 ELSE Invoice.tbItem.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidTaxValue * - 1 ELSE Invoice.tbItem.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
							 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode;
go
ALTER VIEW Invoice.vwRegisterTasks
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidValue * - 1 ELSE InvoiceTask.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidTaxValue * - 1 ELSE InvoiceTask.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbTask AS InvoiceTask ON Invoice.tbInvoice.InvoiceNumber = InvoiceTask.InvoiceNumber INNER JOIN
							 Cash.tbCode ON InvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Task.tbTask AS Task ON InvoiceTask.TaskCode = Task.TaskCode AND InvoiceTask.TaskCode = Task.TaskCode LEFT OUTER JOIN
							 App.tbTaxCode ON InvoiceTask.TaxCode = App.tbTaxCode.TaxCode;
go
ALTER VIEW Invoice.vwSummaryItems
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
							 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue
	FROM            Invoice.tbItem INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
					SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
					INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
					WHERE ( App.tbYear.CashStatusCode < 3)));
go
ALTER VIEW Invoice.vwSummaryTasks
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
							 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * - 1 ELSE Invoice.tbTask.TaxValue END AS TaxValue
	FROM            Invoice.tbTask INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
					SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
					INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
					WHERE ( App.tbYear.CashStatusCode < 3)));
go
ALTER VIEW Task.vwVatConfirmed
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.PaymentOn) ORDER BY p.StartOn DESC) AS StartOn,  
			 CASE WHEN Cash.tbCategory.CashModeCode = 0 
				THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) * App.vwTaxRates.TaxRate * - 1 
				ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) * App.vwTaxRates.TaxRate 
			END AS VatValue
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
							 Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
	WHERE        (App.vwTaxRates.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND 
							 (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
							 * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) * App.vwTaxRates.TaxRate * - 1 END <> 0) AND 
							 (Task.tbTask.PaymentOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions));
go

ALTER VIEW Task.vwVatFull
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.PaymentOn) ORDER BY p.StartOn DESC) AS StartOn,  
							 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
							 * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) * App.vwTaxRates.TaxRate * - 1 END AS VatValue
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
							 Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
	WHERE        (App.vwTaxRates.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode < 3) AND 
							 (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
							 * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) * App.vwTaxRates.TaxRate * - 1 END <> 0);
go
ALTER VIEW Invoice.vwVatItems
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
							 Invoice.tbItem.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
	FROM            Invoice.tbItem INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
	WHERE        (App.tbTaxCode.TaxTypeCode = 1);
go
ALTER VIEW Invoice.vwVatTasks
AS
	SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
							 Invoice.tbTask.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
	FROM            Invoice.tbTask INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
	WHERE        (App.tbTaxCode.TaxTypeCode = 1);
go
DROP FUNCTION IF EXISTS App.fnAccountPeriod;
go

/************ App.fnCashCode **********************/
ALTER FUNCTION Cash.fnTaxCorpOrderTotals
(@IncludeForecasts bit = 0)
RETURNS @tbCorp TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
    AS
	BEGIN
	DECLARE 
		@PayOn datetime
		, @PayFrom datetime
		, @PayTo datetime
		, @NetProfit money
		, @CorporationTax money	
		, @CashCode nvarchar(50)

	SELECT @CashCode = CashCode
	FROM         Cash.tbTaxType
	WHERE     (TaxTypeCode = 0)

	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(0) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		IF (@IncludeForecasts = 0)
			BEGIN
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         Cash.vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			END
		ELSE
			BEGIN
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         Cash.vwCorpTaxTasks
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			END	
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat
	
	RETURN
	END
go
ALTER FUNCTION Cash.fnTaxVatOrderTotals
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	PayIn money,
	PayOut money
	)
    AS
	BEGIN
	DECLARE 
		@PayOn datetime
		, @PayFrom datetime
		, @PayTo datetime	
		, @VatCharge money
		, @CashCode nvarchar(50)

	SELECT @CashCode = CashCode
	FROM         Cash.tbTaxType
	WHERE     (TaxTypeCode = 1)
	
	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		IF (@IncludeForecasts = 0)
			BEGIN
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         Task.vwVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			END
		ELSE
			BEGIN
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         Task.vwVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			END		
						
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	
	RETURN
	END
go
ALTER   PROCEDURE Cash.proc_FlowInitialise
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		EXEC Cash.proc_GeneratePeriods
	
		UPDATE       Cash.tbPeriod
		SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
		FROM            Cash.tbPeriod INNER JOIN
								 Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  ( Cash.tbCategory.CashTypeCode <> 2)
	
		UPDATE Cash.tbPeriod
		SET InvoiceValue = Cash.vwCodeInvoiceSummary.InvoiceValue, 
			InvoiceTax = Cash.vwCodeInvoiceSummary.TaxValue
		FROM         Cash.tbPeriod INNER JOIN
							  Cash.vwCodeInvoiceSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeInvoiceSummary.CashCode AND Cash.tbPeriod.StartOn = Cash.vwCodeInvoiceSummary.StartOn	

		UPDATE Cash.tbPeriod
		SET 
			InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
		FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
							  Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
							  Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn
	                      	
		UPDATE       Cash.tbPeriod
		SET                ForecastValue = Cash.vwCodeForecastSummary.ForecastValue, ForecastTax = Cash.vwCodeForecastSummary.ForecastTax
		FROM            Cash.tbPeriod INNER JOIN
								 Cash.vwCodeForecastSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeForecastSummary.CashCode AND 
								 Cash.tbPeriod.StartOn = Cash.vwCodeForecastSummary.StartOn

		UPDATE Cash.tbPeriod
		SET
			InvoiceValue = Cash.tbPeriod.InvoiceValue + Cash.vwCodeOrderSummary.InvoiceValue,
			InvoiceTax = Cash.tbPeriod.InvoiceTax + Cash.vwCodeOrderSummary.InvoiceTax
		FROM Cash.tbPeriod INNER JOIN
			Cash.vwCodeOrderSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeOrderSummary.CashCode
				AND Cash.tbPeriod.StartOn = Cash.vwCodeOrderSummary.StartOn	
	
		--Corporation Tax		
		UPDATE       Cash.tbPeriod
		SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
		FROM            Cash.tbPeriod
		WHERE CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 0))
	
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = vwTaxCorpStatement.TaxDue
		FROM            Cash.vwTaxCorpStatement INNER JOIN
								 Cash.tbPeriod ON vwTaxCorpStatement.StartOn = Cash.tbPeriod.StartOn
		WHERE        (vwTaxCorpStatement.TaxDue <> 0) AND ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)))
	
		--VAT 		
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = Cash.vwTaxVatStatement.VatDue
		FROM            Cash.vwTaxVatStatement INNER JOIN
								 Cash.tbPeriod ON Cash.vwTaxVatStatement.StartOn = Cash.tbPeriod.StartOn
		WHERE        ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 1))) AND (Cash.vwTaxVatStatement.VatDue <> 0)

		--**********************************************************************************************	                  	

		UPDATE Cash.tbPeriod
		SET
			ForecastValue = Cash.vwFlowNITotals.ForecastNI, 
			InvoiceValue = Cash.vwFlowNITotals.InvoiceNI
		FROM         Cash.tbPeriod INNER JOIN
							  Cash.vwFlowNITotals ON Cash.tbPeriod.StartOn = Cash.vwFlowNITotals.StartOn
		WHERE     ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 2)))
	                      
		COMMIT TRANSACTION	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER FUNCTION Cash.fnStatementTaxEntries(@TaxTypeCode smallint)
RETURNS @tbTax TABLE (
	AccountCode nvarchar(10),
	CashCode nvarchar(50),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	ReferenceCode nvarchar(20),
	PayIn money,
	PayOut money	 
	)
AS
	BEGIN
	DECLARE 
		@AccountCode nvarchar(10)
		, @CashCode nvarchar(50)
		, @TransactOn datetime
		, @InvoiceReferenceCode nvarchar(20) 
		, @OrderReferenceCode nvarchar(20)
		, @CashEntryTypeCode smallint
		, @PayOut money
		, @PayIn money
		, @Balance money
	
	SET @InvoiceReferenceCode = App.fnProfileText(1214)	
	SET @OrderReferenceCode = App.fnProfileText(1215)	

	IF @TaxTypeCode = 0
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 1
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode, @CashCode = CashCode 
	FROM Cash.tbTaxType WHERE (TaxTypeCode = 0) 
	
	DECLARE curCorp CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(TaxDue, 0) AS PayOut, ROUND(TaxPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxCorpStatement
		ORDER BY StartOn DESC
	
	OPEN curCorp
	FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 0) != 0)
		BEGIN		
		IF @PayOut > 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 4, 0, CorporationTax, @CashCode
	FROM Cash.fnTaxCorpOrderTotals(0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode, @CashCode = CashCode 
	FROM Cash.tbTaxType WHERE (TaxTypeCode = 1) 
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(VatDue, 0) AS PayOut, ROUND(VatPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxVatStatement
		ORDER BY StartOn DESC
	
	OPEN curVat
	FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 2) != 0)
		BEGIN		
		IF @PayOut != 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, PayIn, PayOut, @CashCode
	FROM Cash.fnTaxVatOrderTotals(0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END
go
DROP FUNCTION IF EXISTS App.fnCashCode;
go

/*** fnCompanyAccount *********/
ALTER VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT        TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode, 
															  Org.tbAccount.AccountNumber AS BankAccountNumber
									 FROM            Org.tbAccount INNER JOIN
															  Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
									 WHERE        (NOT (Org.tbAccount.CashCode IS NULL))
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber, company.FaxNumber AS CompanyFaxNumber, 
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, 
                              bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Org.tbOrg AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
go							  
DROP FUNCTION IF EXISTS App.fnCompanyAccount;
go
/**** fnVatBalance, fnCorpTaxBalance, Cash.fnCompanyBalance ****/
ALTER VIEW Cash.vwSummaryBase
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) 
	), corp_tax AS
	(
		SELECT 0 AS SummaryId,  ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0) 
			+ ISNULL((SELECT SUM(CorporationTax) FROM Cash.vwCorpTaxInvoice), 0) AS CorpTaxBalance
		FROM         Org.tbPayment INNER JOIN
							  App.vwCorpTaxCashCode ON Org.tbPayment.CashCode = App.vwCorpTaxCashCode.CashCode			
	), vat AS
	(
		SELECT 0 AS SummaryId, ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0) 
			+ (SELECT SUM(VatAdjustment) FROM App.tbYearPeriod) 
			+ (SELECT  SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat) FROM Invoice.vwVatSummary) AS VatBalance
		FROM         Org.tbPayment INNER JOIN
							  App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	
	), invoices AS
	(
		SELECT 0 AS SummaryId, ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) AS TaxValue
		FROM            Cash.vwSummaryInvoices
	)
	SELECT Collect, Pay, TaxValue + VatBalance + CorpTaxBalance AS Tax, CompanyBalance
	FROM company JOIN corp_tax ON company.SummaryId = corp_tax.SummaryId
			JOIN vat ON company.SummaryId = vat.SummaryId
			JOIN invoices ON company.SummaryId = invoices.SummaryId;
go
DROP FUNCTION IF EXISTS App.fnVatBalance;
DROP FUNCTION IF EXISTS App.fnCorpTaxBalance;
DROP FUNCTION IF EXISTS Cash.fnCompanyBalance
go
DROP FUNCTION IF EXISTS Cash.fnCurrentBalance;
go
/**********************/
ALTER   TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		IF UPDATE (Spooled)
			BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT CASE 
					WHEN CashModeCode = 0 THEN		--Expense
						CASE WHEN TaskStatusCode = 0 THEN 2	ELSE 4 END	--Enquiry								
					WHEN CashModeCode = 1 THEN		--Income
						CASE WHEN TaskStatusCode = 0 THEN 0	ELSE 2 END	--Quote
					END AS DocTypeCode, task.TaskCode
			FROM   inserted task INNER JOIN
									 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE (task.Spooled <> 0)

				
			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.TaskCode = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 3)
			END

		IF UPDATE (ContactName)
			BEGIN
			DECLARE contacts CURSOR LOCAL FOR
				SELECT AccountCode, ContactName FROM inserted
				WHERE EXISTS (SELECT     ContactName
						   FROM         inserted AS i
						   WHERE     (NOT (ContactName IS NULL)) AND
												 (ContactName <> N''))
					AND NOT EXISTS(SELECT     Org.tbContact.ContactName
								  FROM         inserted AS i INNER JOIN
														Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)

			DECLARE @AccountCode NVARCHAR(10), @ContactName NVARCHAR(100), @NickName NVARCHAR(100), @FileAs NVARCHAR(100)
				
			OPEN contacts
			FETCH NEXT FROM contacts INTO @AccountCode, @ContactName

			WHILE (@@FETCH_STATUS = 0)
				BEGIN
				SET @NickName = left(@ContactName, CHARINDEX(' ', @ContactName, 1))
				EXEC Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT
					
				INSERT INTO Org.tbContact (AccountCode, ContactName, FileAs, NickName)
				VALUES (@AccountCode, @ContactName, @FileAs, @NickName)

				FETCH NEXT FROM contacts INTO @AccountCode, @ContactName
				END					
		
			CLOSE contacts
			DEALLOCATE contacts
			END


		DECLARE @TaskCode NVARCHAR(20)

		IF UPDATE (TaskStatusCode)
			BEGIN
			DECLARE tasks CURSOR LOCAL FOR
				SELECT        i.TaskCode, i.TaskStatusCode
				FROM  inserted AS i INNER JOIN Task.tbTask AS t ON i.TaskCode = t.TaskCode AND i.TaskStatusCode <> t.TaskStatusCode 

			DECLARE @TaskStatusCode smallint

			OPEN tasks
			FETCH NEXT FROM tasks INTO @TaskCode, @TaskStatusCode

			WHILE (@@FETCH_STATUS = 0)
				BEGIN
				IF @TaskStatusCode <> 3
					EXEC Task.proc_SetStatus @TaskCode
				ELSE
					EXEC Task.proc_SetOpStatus @TaskCode, @TaskStatusCode

				FETCH NEXT FROM tasks INTO @TaskCode, @TaskStatusCode
				END

			CLOSE tasks
			DEALLOCATE tasks			
			END
		
	
		IF UPDATE (ActionOn) AND EXISTS (SELECT * FROM App.tbOptions WHERE ScheduleOps <> 0)
			BEGIN
			DECLARE ops CURSOR LOCAL FOR
				SELECT TaskCode, ActionOn FROM inserted
		
			DECLARE @ActionOn datetime

			OPEN ops
			FETCH NEXT FROM ops INTO @TaskCode, @ActionOn

			WHILE (@@FETCH_STATUS = 0)
				BEGIN
				EXEC Task.proc_ScheduleOp @TaskCode, @ActionOn
				FETCH NEXT FROM ops INTO @TaskCode, @ActionOn
				END

			CLOSE ops
			DEALLOCATE ops
			END	

		UPDATE Task.tbTask
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
DROP FUNCTION IF EXISTS App.fnDocTaskType;
go
DROP FUNCTION IF EXISTS App.fnTaxHorizon;
go

/*** fnProfileText **********/
ALTER FUNCTION Org.fnStatement
	(
	@AccountCode nvarchar(10)
	)
RETURNS @tbStatement TABLE (TransactedOn datetime, OrderBy smallint, Reference nvarchar(50), StatementType nvarchar(20), Charge money, Balance money)
  AS
	BEGIN
	DECLARE 
		@TransactedOn datetime
		, @OrderBy smallint
		, @Reference nvarchar(50)
		, @StatementType nvarchar(20)
		, @Charge money
		, @Balance money
	
	SELECT TOP 1 @StatementType = [Message] FROM App.tbText WHERE TextId = 3005
	SELECT @Balance = OpeningBalance FROM Org.tbOrg WHERE AccountCode = @AccountCode
	
	SELECT   @TransactedOn = MIN(TransactedOn) 
	FROM         Org.vwStatementBase
	WHERE     (AccountCode = @AccountCode)
	
	INSERT INTO @tbStatement (TransactedOn, OrderBy, StatementType, Charge, Balance)
	VALUES (DATEADD(d, -1, @TransactedOn), 0, @StatementType, @Balance, @Balance)
	 
	DECLARE curAc cursor local for
		SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         Org.vwStatementBase
		WHERE     (AccountCode = @AccountCode)
		ORDER BY TransactedOn, OrderBy

	OPEN curAc
	FETCH NEXT FROM curAc INTO @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @Balance = @Balance + @Charge
		INSERT INTO @tbStatement (TransactedOn, OrderBy, Reference, StatementType, Charge, Balance)
		VALUES (@TransactedOn, @OrderBy, @Reference, @StatementType, @Charge, @Balance)
		
		FETCH NEXT FROM curAc INTO @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
		END
	
	CLOSE curAc
	DEALLOCATE curAc
		
	RETURN
	END
go
ALTER FUNCTION Cash.fnStatementTaxEntries(@TaxTypeCode smallint)
RETURNS @tbTax TABLE (
	AccountCode nvarchar(10),
	CashCode nvarchar(50),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	ReferenceCode nvarchar(20),
	PayIn money,
	PayOut money	 
	)
AS
	BEGIN
	DECLARE 
		@AccountCode nvarchar(10)
		, @CashCode nvarchar(50)
		, @TransactOn datetime
		, @InvoiceReferenceCode nvarchar(20) 
		, @OrderReferenceCode nvarchar(20)
		, @CashEntryTypeCode smallint
		, @PayOut money
		, @PayIn money
		, @Balance money
	
	SELECT @InvoiceReferenceCode = [Message] FROM App.tbText WHERE TextId = 1214
	SELECT @OrderReferenceCode = [Message] FROM App.tbText WHERE TextId = 1215

	IF @TaxTypeCode = 0
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 1
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode, @CashCode = CashCode 
	FROM Cash.tbTaxType WHERE (TaxTypeCode = 0) 
	
	DECLARE curCorp CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(TaxDue, 0) AS PayOut, ROUND(TaxPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxCorpStatement
		ORDER BY StartOn DESC
	
	OPEN curCorp
	FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 0) != 0)
		BEGIN		
		IF @PayOut > 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 4, 0, CorporationTax, @CashCode
	FROM Cash.fnTaxCorpOrderTotals(0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode, @CashCode = CashCode 
	FROM Cash.tbTaxType WHERE (TaxTypeCode = 1) 
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(VatDue, 0) AS PayOut, ROUND(VatPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxVatStatement
		ORDER BY StartOn DESC
	
	OPEN curVat
	FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 2) != 0)
		BEGIN		
		IF @PayOut != 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, PayIn, PayOut, @CashCode
	FROM Cash.fnTaxVatOrderTotals(0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END
go
ALTER TRIGGER App.App_tbCalendar_TriggerUpdate 
   ON  App.tbCalendar
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CalendarCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER FUNCTION Cash.fnStatementCompany()
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money,
	CashCode nvarchar(50)
	) 
   AS
	BEGIN
	DECLARE 
		@ReferenceCode nvarchar(20) 
		, @CashCode nvarchar(50)
		, @AccountCode nvarchar(10)
		, @TransactOn datetime
		, @CashEntryTypeCode smallint
		, @PayOut money
		, @PayIn money
		, @Balance money

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, 1 AS CashEntryTypeCode, Invoice.tbItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 0 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 2 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbItem INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE  (InvoiceStatusCode < 3) AND (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
	GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, 1 AS CashEntryTypeCode, Invoice.tbTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 0 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 2 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE  (InvoiceStatusCode < 3) AND  (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
	GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbTask.CashCode
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         Cash.vwStatementTasksConfirmed			
	
	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 0))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 1))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	SELECT @ReferenceCode = [Message] FROM App.tbText WHERE TextId = 3013

	SELECT    @Balance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount INNER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0)	

	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
			
	DECLARE curSt cursor local for
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	OPEN curSt
	
	FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @PayIn - @PayOut
		IF @CashCode IS NULL
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		END
	CLOSE curSt
	DEALLOCATE curSt
		
	RETURN
	END
go
ALTER FUNCTION Cash.fnStatementReserves ()
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money, 
	CashCode nvarchar(50)
	) 
AS
	BEGIN
	DECLARE 
		@ReferenceCode nvarchar(20) 
		, @ReferenceCode2 nvarchar(20)
		, @CashCode nvarchar(50)
		, @AccountCode nvarchar(10)
		, @TransactOn datetime
		, @CashEntryTypeCode smallint
		, @PayOut money
		, @PayIn money
		, @Balance money
		, @Now datetime

	SELECT @ReferenceCode = [Message] FROM App.tbText WHERE TextId = 1219

	SELECT    @Balance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount LEFT OUTER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0) AND ( Cash.tbCode.CashCode IS NULL)
		
	SELECT @TransactOn = MAX( Org.tbPayment.PaidOn)
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode LEFT OUTER JOIN
						  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Cash.tbCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 0, 0, 0, @Balance)

	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
		FROM            Cash.tbTaxType INNER JOIN
								 Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 0) AND ( Cash.tbCode.CashCode IS NULL))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
		FROM            Cash.tbTaxType INNER JOIN
								 Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 1) AND ( Cash.tbCode.CashCode IS NULL))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END
			
	DECLARE curReserve cursor local for
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	OPEN curReserve
	
	FETCH NEXT FROM curReserve INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @PayIn - @PayOut
		IF @CashCode IS NULL
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		FETCH NEXT FROM curReserve INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		END
	CLOSE curReserve
	DEALLOCATE curReserve

	RETURN
	END
go
ALTER   TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN	
			UPDATE Org.tbAccount
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
DROP TRIGGER IF EXISTS Cash.App_tbCategory_TriggerUpdate
go
ALTER TRIGGER Cash.Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			UPDATE Cash.tbCategory
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TRIGGER App.App_tbUom_TriggerUpdate
   ON  App.tbUom
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(UnitOfMeasure) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER VIEW Cash.vwAccountStatementBase
AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Org.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)		
		UNION
		SELECT        Org.tbAccount.CashAccountCode, 0 AS EntryNumber, 
			(SELECT CAST([Message] AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, DATEADD(HOUR, - 1, MIN(Org.tbPayment.PaidOn)) AS PaidOn, Org.tbAccount.OpeningBalance AS PaidBalance
		FROM            Org.tbAccount INNER JOIN
								 Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbAccount.AccountClosed = 0)
		GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.OpeningBalance
	)
	SELECT CashAccountCode, EntryNumber, PaymentCode, PaidOn, 
		SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
	FROM entries
go
ALTER VIEW [Invoice].[vwSummaryMargin]
  AS
SELECT     StartOn, 4 AS InvoiceTypeCode, (SELECT CAST([Message] AS NVARCHAR(10)) FROM App.tbText WHERE TextId = 3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         Invoice.vwSummaryTotals
GROUP BY StartOn
go
ALTER   TRIGGER Activity.Activity_tbActivity_TriggerUpdate
   ON  Activity.tbActivity
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(ActivityCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN
			UPDATE Activity.tbActivity
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Activity.tbActivity INNER JOIN inserted AS i ON tbActivity.ActivityCode = i.ActivityCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TRIGGER Cash.Cash_tbCode_TriggerUpdate
   ON  Cash.tbCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
		ELSE
			BEGIN
			UPDATE Cash.tbCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TRIGGER Org.Org_tbOrg_TriggerUpdate 
   ON  Org.tbOrg
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(AccountCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK TRANSACTION;
			END
		ELSE
			BEGIN
			UPDATE Org.tbOrg
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbOrg INNER JOIN inserted AS i ON tbOrg.AccountCode = i.AccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER   TRIGGER App.App_tbTaxCode_TriggerUpdate
   ON  App.tbTaxCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(TaxCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK TRANSACTION;
			END
		ELSE
			BEGIN
			UPDATE App.tbTaxCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM App.tbTaxCode INNER JOIN inserted AS i ON tbTaxCode.TaxCode = i.TaxCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
DROP FUNCTION IF EXISTS App.fnProfileText;
go
ALTER VIEW Cash.vwTaxCorpStatement
AS
	SELECT        TOP (100) PERCENT StartOn, TaxDue, TaxPaid, Balance
	FROM            Cash.fnTaxCorpStatement() AS fnTaxCorpStatement
	WHERE        (StartOn > (SELECT  MIN( App.tbYearPeriod.StartOn) FROM App.tbYear INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber	WHERE ( App.tbYear.CashStatusCode < 3)))
	ORDER BY StartOn, TaxDue
go
ALTER VIEW [Cash].[vwTaxVatStatement]
AS
	SELECT        TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
	FROM            Cash.fnTaxVatStatement() AS fnTaxVatStatement
	WHERE        (StartOn > (SELECT  MIN( App.tbYearPeriod.StartOn) FROM App.tbYear INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber	WHERE ( App.tbYear.CashStatusCode < 3)))
	ORDER BY StartOn, VatDue
go
DROP FUNCTION IF EXISTS App.fnHistoryStartOn
go
ALTER VIEW Org.vwDatasheet
AS
	SELECT        o.AccountCode, o.AccountName, ISNULL(Org.vwTaskCount.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.FaxNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, o.StatementDays, 
							 o.OpeningBalance, o.CurrentBalance, o.ForeignJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn, o.PayDaysFromMonthEnd
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 Org.vwTaskCount ON o.AccountCode = Org.vwTaskCount.AccountCode
go
DROP FUNCTION IF EXISTS Org.fnIndustrySectors
DROP FUNCTION IF EXISTS Cash.fnReserveBalance
DROP FUNCTION IF EXISTS App.fnActiveStartOn
DROP FUNCTION IF EXISTS Org.fnStatementTaxAccount
DROP FUNCTION IF EXISTS Cash.fnCodeDefaultAccount
DROP FUNCTION IF EXISTS fnDocInvoiceType
DROP FUNCTION IF EXISTS App.fnDateBucket
go
UPDATE App.tbOptions
SET SQLDataVersion = 3.06;
go





