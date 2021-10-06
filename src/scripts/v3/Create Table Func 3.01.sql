/************************************************************
TABLE VALUED FUNCTIONS
************************************************************/

--Dependent objects
CREATE VIEW App.vwVatCashCode
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 2)
GO
ALTER AUTHORIZATION ON App.vwVatCashCode TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwInvoicedQuantity
  AS
SELECT     Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
WHERE     (Invoice.tbInvoice.InvoiceTypeCode = 1) OR
                      (Invoice.tbInvoice.InvoiceTypeCode = 3)
GROUP BY Invoice.tbTask.TaskCode
GO
ALTER AUTHORIZATION ON Task.vwInvoicedQuantity TO  SCHEMA OWNER 
GO
CREATE VIEW App.vwTaxRates
AS
SELECT     TaxCode, CAST(TaxRate AS MONEY) AS TaxRate, TaxTypeCode
FROM         App.tbTaxCode
GO
ALTER AUTHORIZATION ON App.vwTaxRates TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwVatConfirmed
AS
SELECT     App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate END AS VatValue
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (App.vwTaxRates.TaxTypeCode = 2) AND (Task.tbTask.TaskStatusCode > 1) AND (Task.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END <> 0) AND (Task.tbTask.PaymentOn <= DATEADD(d, App.fnTaxHorizon(), SYSDATETIME()))

GO
ALTER AUTHORIZATION ON Task.vwVatConfirmed TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwVatFull
  AS
SELECT     App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END AS VatValue
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (App.vwTaxRates.TaxTypeCode = 2) AND (Task.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END <> 0)

GO
ALTER AUTHORIZATION ON Task.vwVatFull TO  SCHEMA OWNER 
GO

CREATE VIEW Cash.vwCorpTaxTasksBase
AS
SELECT     TOP 100 PERCENT Task.tbTask.TaskCode, Task.tbStatus.TaskStatus, App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
                      * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         Task.tbStatus INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
                      Cash.tbCategory INNER JOIN
                      Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode < 4) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxTasksBase TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCorpTaxTasks
  AS
SELECT     Cash.vwCorpTaxTasksBase.StartOn, SUM(Cash.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      Cash.vwCorpTaxTasksBase.OrderValue * App.tbYearPeriod.CorporationTaxRate AS CorporationTax
FROM         Cash.vwCorpTaxTasksBase INNER JOIN
                      App.tbYearPeriod ON Cash.vwCorpTaxTasksBase.StartOn = App.tbYearPeriod.StartOn
GROUP BY Cash.vwCorpTaxTasksBase.StartOn, Cash.vwCorpTaxTasksBase.OrderValue * App.tbYearPeriod.CorporationTaxRate
GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCorpTaxConfirmedBase
AS
SELECT        TOP (100) PERCENT App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                         CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
                         * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM            Task.vwInvoicedQuantity RIGHT OUTER JOIN
                         Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
                         Cash.tbCategory INNER JOIN
                         Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON 
                         fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.vwInvoicedQuantity.TaskCode = Task.tbTask.TaskCode
WHERE        (Task.tbTask.TaskStatusCode > 1) AND (Task.tbTask.TaskStatusCode < 4) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0) AND 
                         (Task.tbTask.PaymentOn <= DATEADD(d, App.fnTaxHorizon(), SYSDATETIME()))

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxConfirmedBase TO  SCHEMA OWNER 
GO

GO

GO
CREATE VIEW Cash.vwCorpTaxConfirmed
AS
SELECT        Cash.vwCorpTaxConfirmedBase.StartOn, SUM(Cash.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                         SUM(Cash.vwCorpTaxConfirmedBase.OrderValue * App.tbYearPeriod.CorporationTaxRate) AS CorporationTax
FROM            Cash.vwCorpTaxConfirmedBase INNER JOIN
                         App.tbYearPeriod ON Cash.vwCorpTaxConfirmedBase.StartOn = App.tbYearPeriod.StartOn
GROUP BY Cash.vwCorpTaxConfirmedBase.StartOn

GO
ALTER AUTHORIZATION ON Cash.vwCorpTaxConfirmed TO  SCHEMA OWNER 
GO
CREATE  FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode SMALLINT)
RETURNS @tbDueDate TABLE (PayOn DATETIME, PayFrom DATETIME, PayTo DATETIME)
 AS
	BEGIN
	DECLARE @MonthNumber SMALLINT
	DECLARE @RecurrenceCode SMALLINT
	DECLARE @MonthInterval SMALLINT
	DECLARE @StartOn DATETIME
	
	SELECT @MonthNumber = MonthNumber, @RecurrenceCode = RecurrenceCode
	FROM Cash.tbTaxType
	WHERE TaxTypeCode = @TaxTypeCode
	
	SET @MonthInterval = CASE @RecurrenceCode
		WHEN 1 THEN 1
		WHEN 2 THEN 1
		WHEN 3 THEN 3
		WHEN 4 THEN 6
		WHEN 5 THEN 12
		END
				
	SELECT   @StartOn = MIN(StartOn)
	FROM         App.tbYearPeriod
	WHERE     (MonthNumber = @MonthNumber)
	ORDER BY MIN(StartOn)
	
	INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
	SET @MonthNumber = CASE 
		WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
		ELSE (@MonthNumber + @MonthInterval) % 12
		END
	
	WHILE exists(SELECT     MonthNumber
	             FROM         App.tbYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
	    FROM         App.tbYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
		
		END
	
	-- Set PayTo
	DECLARE @PayOn DATETIME
	DECLARE @PayFrom DATETIME
		
	IF (@TaxTypeCode = 1)
		GOTO CorporationTax
	ELSE
		GOTO VatTax
		
	RETURN
	
CorporationTax:

	SELECT @StartOn = MIN(StartOn)
	FROM App.tbYearPeriod
	ORDER BY MIN(StartOn)
	
	SET @PayFrom = @StartOn
	
	SELECT @MonthNumber = MonthNumber
	FROM         App.tbYearPeriod
	WHERE StartOn = @StartOn

	SET @MonthNumber = CASE 
		WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
		ELSE (@MonthNumber + @MonthInterval) % 12
		END
	
	WHILE exists(SELECT     MonthNumber
	             FROM         App.tbYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
	    FROM         App.tbYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		
		SELECT @PayOn = MIN(PayOn)
		FROM @tbDueDate
		WHERE PayOn >= @StartOn
		ORDER BY min(PayOn)
		
		UPDATE @tbDueDate
		SET PayTo = @StartOn, PayFrom = @PayFrom
		WHERE PayOn = @PayOn
		
		SET @PayFrom = @StartOn
		
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
		
		END

	DELETE FROM @tbDueDate WHERE PayTo is null
	
	RETURN

VatTax:

	DECLARE curTemp CURSOR FOR
		SELECT PayOn FROM @tbDueDate
		ORDER BY PayOn

	OPEN curTemp
	FETCH NEXT FROM curTemp INTO @PayOn	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		UPDATE @tbDueDate
		SET 
			PayFrom = DATEADD(m, @MonthInterval * -1, @PayOn),
			PayTo = @PayOn
		WHERE PayOn = @PayOn

		FETCH NEXT FROM curTemp INTO @PayOn	
		END

	CLOSE curTemp
	DEALLOCATE curTemp
	
	RETURN
	
	END
GO

CREATE FUNCTION Cash.fnTaxVatTotals
	()
RETURNS @tbVat TABLE 
	(
	StartOn DATETIME, 
	HomeSales MONEY,
	HomePurchases MONEY,
	ExportSales MONEY,
	ExportPurchases MONEY,
	HomeSalesVat MONEY,
	HomePurchasesVat MONEY,
	ExportSalesVat MONEY,
	ExportPurchasesVat MONEY,
	VatAdjustment MONEY,
	VatDue MONEY
	)
  AS
	BEGIN
	DECLARE @PayOn DATETIME
	DECLARE @PayFrom DATETIME
	DECLARE @PayTo DATETIME
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbVat (StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(HomeSales), 0) AS HomeSales, ISNULL(SUM(HomePurchases), 0) AS HomePurchases, ISNULL(SUM(ExportSales), 0) AS ExportSales, 
		                      ISNULL(SUM(ExportPurchases), 0) AS ExportPurchases, ISNULL(SUM(HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(HomePurchasesVat), 0) AS HomePurchasesVat, 
		                      ISNULL(SUM(ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM         Invoice.vwVatSummary
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	UPDATE @tbVat
	SET VatAdjustment = App.tbYearPeriod.VatAdjustment
	FROM @tbVat AS tb INNER JOIN
	                      App.tbYearPeriod ON tb.StartOn = App.tbYearPeriod.StartOn
	
	UPDATE @tbVat
	SET VatDue = (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) + VatAdjustment
	
	RETURN
	END
GO
CREATE FUNCTION Cash.fnTaxVatStatement()
RETURNS @tbVat TABLE 
	(
	StartOn DATETIME, 
	VatDue MONEY ,
	VatPaid MONEY ,
	Balance MONEY
	)
  AS
	BEGIN
	DECLARE @Balance MONEY
	DECLARE @StartOn DATETIME
	DECLARE @VatDue MONEY
	DECLARE @VatPaid MONEY
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     StartOn, VatDue, 0 As VatPaid, 0 AS Balance
	FROM         Cash.fnTaxVatTotals() fnTaxVatTotals	
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     Org.tbPayment.PaidOn, 0 As VatDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS VatPaid, 0 As Balance
	FROM         Org.tbPayment INNER JOIN
	                      App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	                      

	SET @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, VatDue, VatPaid
		FROM @tbVat
		ORDER BY StartOn, VatDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @VatDue + @VatPaid
		UPDATE @tbVat
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND VatDue = @VatDue 
		FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO

CREATE VIEW Cash.vwTaxVatStatement
AS
SELECT        TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
FROM            Cash.fnTaxVatStatement() AS fnTaxVatStatement
WHERE        (StartOn > App.fnHistoryStartOn())
ORDER BY StartOn, VatDue
GO
ALTER AUTHORIZATION ON Cash.vwTaxVatStatement TO  SCHEMA OWNER 
GO
CREATE FUNCTION Cash.fnTaxCorpTotals
()
RETURNS @tbCorp TABLE 
	(
	StartOn DATETIME, 
	NetProfit MONEY,
	CorporationTax MONEY
	)
 AS
	BEGIN
	DECLARE @PayOn DATETIME
	DECLARE @PayFrom DATETIME
	DECLARE @PayTo DATETIME
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
		FROM         Cash.vwCorpTaxInvoice
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	
	RETURN
	END
GO
CREATE FUNCTION Cash.fnTaxCorpStatement()
RETURNS @tbCorp TABLE 
	(
	StartOn DATETIME, 
	TaxDue MONEY ,
	TaxPaid MONEY ,
	Balance MONEY
	)
  AS
	BEGIN
	DECLARE @Balance MONEY
	DECLARE @StartOn DATETIME
	DECLARE @TaxDue MONEY
	DECLARE @TaxPaid MONEY
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     StartOn, ROUND(CorporationTax, 2), 0 As TaxPaid, 0 AS Balance
	FROM         Cash.fnTaxCorpTotals() fnTaxCorpTotals		
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     Org.tbPayment.PaidOn, 0 As TaxDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS TaxPaid, 0 As Balance
	FROM         Org.tbPayment INNER JOIN
	                      App.vwCorpTaxCashCode ON Org.tbPayment.CashCode = App.vwCorpTaxCashCode.CashCode	                      

	SET @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, TaxDue, TaxPaid
		FROM @tbCorp
		ORDER BY StartOn, TaxDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @TaxDue + @TaxPaid
		UPDATE @tbCorp
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND TaxDue = @TaxDue 
		FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO

CREATE VIEW Cash.vwTaxCorpStatement
AS
SELECT     TOP (100) PERCENT StartOn, TaxDue, TaxPaid, Balance
FROM         Cash.fnTaxCorpStatement() AS fnTaxCorpStatement
WHERE     (StartOn > App.fnHistoryStartOn())
ORDER BY StartOn, TaxDue

GO
ALTER AUTHORIZATION ON Cash.vwTaxCorpStatement TO  SCHEMA OWNER 
GO

CREATE VIEW Cash.vwStatementTasksConfirmed
 AS
SELECT     TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.ActionOn, Task.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 2 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
FROM         App.vwTaxRates INNER JOIN
                      Task.tbTask ON App.vwTaxRates.TaxCode = Task.tbTask.TaxCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode > 1) AND (Task.tbTask.TaskStatusCode < 4) AND 
                      (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
ALTER AUTHORIZATION ON Cash.vwStatementTasksConfirmed TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwStatementPayments
  AS
SELECT     TOP 100 PERCENT Org.tbPayment.AccountCode, Org.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      Org.tbPayment.PaymentReference AS Reference, Org.tbPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         Org.tbPayment INNER JOIN
                      Org.tbPaymentStatus ON Org.tbPayment.PaymentStatusCode = Org.tbPaymentStatus.PaymentStatusCode
ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn
GO
ALTER AUTHORIZATION ON Org.vwStatementPayments TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwStatementPaymentBase
  AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         Org.vwStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO
ALTER AUTHORIZATION ON Org.vwStatementPaymentBase TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwStatementInvoices
  AS
SELECT     TOP 100 PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, 
                      Invoice.tbType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue WHEN 2 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn
GO
ALTER AUTHORIZATION ON Org.vwStatementInvoices TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwStatementBase
  AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         Org.vwStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         Org.vwStatementInvoices
GO
ALTER AUTHORIZATION ON Org.vwStatementBase TO  SCHEMA OWNER 
GO


--Table-valued functions
CREATE FUNCTION Cash.fnAccountStatement
	(
		@CashAccountCode NVARCHAR(10)
	)
RETURNS @tbCash TABLE (EntryNumber int, PaymentCode NVARCHAR(20), PaidOn DATETIME, PaidBalance MONEY, TaxedBalance MONEY)
  AS
	BEGIN
	DECLARE @EntryNumber int
	DECLARE @PaymentCode NVARCHAR(20)
	DECLARE @PaidOn DATETIME
	DECLARE @Paid MONEY
	DECLARE @Taxed MONEY
	DECLARE @PaidBalance MONEY
	DECLARE @TaxedBalance MONEY
		
	SELECT   @PaidBalance = OpeningBalance
	FROM         Org.tbAccount
	WHERE     (CashAccountCode = @CashAccountCode)

	SELECT    @PaidOn = MIN(PaidOn) 
	FROM         Org.tbPayment
	WHERE     (CashAccountCode = @CashAccountCode)
	
	SET @EntryNumber = 1
		
	INSERT INTO @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
	VALUES (@EntryNumber, App.fnProfileText(3005), DATEADD(d, -1, @PaidOn), @PaidBalance, 0) 

	SET @EntryNumber = @EntryNumber + 1
	SET @TaxedBalance = 0
	
	DECLARE curCash CURSOR LOCAL FOR
		SELECT     PaymentCode, PaidOn, CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid, 
		                      TaxOutValue - TaxInValue AS Taxed
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 2) AND (CashAccountCode = @CashAccountCode)
		ORDER BY PaidOn

	OPEN curCash
	FETCH NEXT FROM curCash INTO @PaymentCode, @PaidOn, @Paid, @Taxed
	WHILE @@FETCH_STATUS = 0
		BEGIN	
		SET @PaidBalance = @PaidBalance + @Paid
		SET @TaxedBalance = @TaxedBalance + @Taxed
		INSERT INTO @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		VALUES (@EntryNumber, @PaymentCode, @PaidOn, @PaidBalance, @TaxedBalance) 
		
		SET @EntryNumber = @EntryNumber + 1
		FETCH NEXT FROM curCash INTO @PaymentCode, @PaidOn, @Paid, @Taxed
		END
	
	CLOSE curCash
	DEALLOCATE curCash
		
	RETURN
	END



GO
CREATE FUNCTION Cash.fnAccountStatements
()
RETURNS  @tbCashAccount TABLE (CashAccountCode NVARCHAR(20), EntryNumber int, PaymentCode NVARCHAR(20), PaidOn DATETIME, PaidBalance MONEY, TaxedBalance MONEY)
  AS
	BEGIN
	DECLARE @CashAccountCode NVARCHAR(20)
	DECLARE curAccount CURSOR LOCAL FOR 
		SELECT     CashAccountCode
		FROM         Org.tbAccount
		WHERE     (AccountClosed = 0)
		ORDER BY CashAccountCode

	OPEN curAccount
	FETCH NEXT FROM curAccount INTO @CashAccountCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO @tbCashAccount (CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		SELECT     @CashAccountCode As CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance
		FROM         Cash.fnAccountStatement(@CashAccountCode) fnCashAccountStatement		
		FETCH NEXT FROM curAccount INTO @CashAccountCode
		END
	
	CLOSE curAccount
	DEALLOCATE curAccount
	
	RETURN
	END
GO
CREATE FUNCTION Org.fnStatement
	(
	@AccountCode NVARCHAR(10)
	)
RETURNS @tbStatement TABLE (TransactedOn DATETIME, OrderBy SMALLINT, Reference NVARCHAR(50), StatementType NVARCHAR(20), Charge MONEY, Balance MONEY)
  AS
	BEGIN
	DECLARE @TransactedOn DATETIME
	DECLARE @OrderBy SMALLINT
	DECLARE @Reference NVARCHAR(50)
	DECLARE @StatementType NVARCHAR(20)
	DECLARE @Charge MONEY
	DECLARE @Balance MONEY
	
	SELECT @StatementType = App.fnProfileText(3005)
	SELECT @Balance = OpeningBalance FROM Org.tbOrg WHERE AccountCode = @AccountCode
	
	SELECT   @TransactedOn = MIN(TransactedOn) 
	FROM         Org.vwStatementBase
	WHERE     (AccountCode = @AccountCode)
	
	INSERT INTO @tbStatement (TransactedOn, OrderBy, StatementType, Charge, Balance)
	VALUES (DATEADD(d, -1, @TransactedOn), 0, @StatementType, @Balance, @Balance)
	 
	DECLARE curAc CURSOR LOCAL FOR
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


GO

CREATE FUNCTION Cash.fnTaxCorpOrderTotals
(@IncludeForecasts bit = 0)
RETURNS @tbCorp TABLE 
	(
	CashCode NVARCHAR(50),
	StartOn DATETIME, 
	NetProfit MONEY,
	CorporationTax MONEY
	)
    AS
	BEGIN
	DECLARE @PayOn DATETIME
	DECLARE @PayFrom DATETIME
	DECLARE @PayTo DATETIME
	
	DECLARE @NetProfit MONEY
	DECLARE @CorporationTax MONEY
	
	DECLARE @CashCode NVARCHAR(50)
	SET @CashCode = App.fnCashCode(1)
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
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
GO
CREATE FUNCTION Cash.fnTaxVatOrderTotals
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	CashCode NVARCHAR(50),
	StartOn DATETIME, 
	PayIn MONEY,
	PayOut MONEY
	)
    AS
	BEGIN
	DECLARE @PayOn DATETIME
	DECLARE @PayFrom DATETIME
	DECLARE @PayTo DATETIME
	
	DECLARE @VatCharge MONEY
	
	DECLARE @CashCode NVARCHAR(50)
	SET @CashCode = App.fnCashCode(2)
	
	DECLARE curVat CURSOR LOCAL FOR
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
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
GO
CREATE FUNCTION Cash.fnStatementTaxEntries(@TaxTypeCode SMALLINT)
RETURNS @tbTax TABLE (
	AccountCode NVARCHAR(10),
	CashCode NVARCHAR(50),
	TransactOn DATETIME,
	CashEntryTypeCode SMALLINT,
	ReferenceCode NVARCHAR(20),
	PayIn MONEY,
	PayOut MONEY	 
	)
AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	DECLARE @CashCode NVARCHAR(50)
	DECLARE @TransactOn DATETIME
	DECLARE @InvoiceReferenceCode NVARCHAR(20) 
	DECLARE @OrderReferenceCode NVARCHAR(20)
	DECLARE @CashEntryTypeCode SMALLINT
	DECLARE @PayOut MONEY
	DECLARE @PayIn MONEY
	DECLARE @Balance MONEY
	
	SET @InvoiceReferenceCode = App.fnProfileText(1214)	
	SET @OrderReferenceCode = App.fnProfileText(1215)	

	IF @TaxTypeCode = 1
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 2
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 1) 
	SET @CashCode = App.fnCashCode(1)
	
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
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, 0, CorporationTax, @CashCode
	FROM Cash.fnTaxCorpOrderTotals(0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 2) 
	SET @CashCode = App.fnCashCode(2)

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
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 6, PayIn, PayOut, @CashCode
	FROM Cash.fnTaxVatOrderTotals(0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END

GO
CREATE FUNCTION Cash.fnStatementCompany()
RETURNS @tbStatement TABLE (
	ReferenceCode NVARCHAR(20), 
	AccountCode NVARCHAR(10),
	TransactOn DATETIME,
	CashEntryTypeCode SMALLINT,
	PayOut MONEY,
	PayIn MONEY,
	Balance MONEY,
	CashCode NVARCHAR(50)
	) 
   AS
	BEGIN
	DECLARE @ReferenceCode NVARCHAR(20) 
	DECLARE @CashCode NVARCHAR(50)
	DECLARE @AccountCode NVARCHAR(10)
	DECLARE @TransactOn DATETIME
	DECLARE @CashEntryTypeCode SMALLINT
	DECLARE @PayOut MONEY
	DECLARE @PayIn MONEY
	DECLARE @Balance MONEY

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, 2 AS CashEntryTypeCode, Invoice.tbItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbItem INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
	GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, 2 AS CashEntryTypeCode, Invoice.tbTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
	GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbTask.CashCode
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         Cash.vwStatementTasksConfirmed			
	
	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 1))
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
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 2))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	SELECT @ReferenceCode = App.fnProfileText(3013)
	SET @Balance = Cash.fnCurrentBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
			
	DECLARE curSt CURSOR LOCAL FOR
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		ORDER BY TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

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


GO
CREATE FUNCTION Cash.fnStatementReserves ()
RETURNS @tbStatement TABLE (
	ReferenceCode NVARCHAR(20), 
	AccountCode NVARCHAR(10),
	TransactOn DATETIME,
	CashEntryTypeCode SMALLINT,
	PayOut MONEY,
	PayIn MONEY,
	Balance MONEY, 
	CashCode NVARCHAR(50)
	) 
AS
	BEGIN
	DECLARE @ReferenceCode NVARCHAR(20) 
	DECLARE @ReferenceCode2 NVARCHAR(20)
	DECLARE @CashCode NVARCHAR(50)
	DECLARE @AccountCode NVARCHAR(10)
	DECLARE @TransactOn DATETIME
	DECLARE @CashEntryTypeCode SMALLINT
	DECLARE @PayOut MONEY
	DECLARE @PayIn MONEY
	DECLARE @Balance MONEY
	DECLARE @Now DATETIME

	SELECT @ReferenceCode = App.fnProfileText(1219)
	SET @Balance = Cash.fnReserveBalance()	
	SELECT @TransactOn = MAX( Org.tbPayment.PaidOn)
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode LEFT OUTER JOIN
						  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Cash.tbCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)

	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
		FROM            Cash.tbTaxType INNER JOIN
								 Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 1) AND ( Cash.tbCode.CashCode IS NULL))
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
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 2) AND ( Cash.tbCode.CashCode IS NULL))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END
			
	DECLARE curReserve CURSOR LOCAL FOR
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		ORDER BY TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

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
GO
CREATE FUNCTION Org.fnRebuildInvoiceItems
	(
	@AccountCode NVARCHAR(10)
	)
RETURNS TABLE
 AS
	RETURN ( SELECT     Invoice.tbInvoice.InvoiceNumber, ROUND(SUM( Invoice.tbItem.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM( Invoice.tbItem.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         Invoice.tbItem INNER JOIN
	                               Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	         WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber )

GO
CREATE FUNCTION Org.fnRebuildInvoiceTasks
	(
	@AccountCode NVARCHAR(10)
	)
RETURNS TABLE
 AS
	RETURN ( SELECT     Invoice.tbInvoice.InvoiceNumber, ROUND(SUM( Invoice.tbTask.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM( Invoice.tbTask.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         Invoice.tbTask INNER JOIN
	                               Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	         WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber )
GO


