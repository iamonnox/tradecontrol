
ALTER PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRANSACTION
			
			EXEC Invoice.proc_Total @InvoiceNumber
			
			UPDATE    Invoice.tbInvoice
			SET              InvoiceStatusCode = 1
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 0); 
	
			WITH invoiced_quantity AS
			(
				SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
				FROM            Invoice.tbTask INNER JOIN
										 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
										 (Invoice.tbInvoice.InvoiceTypeCode = 2)
				GROUP BY Invoice.tbTask.TaskCode
			)
			UPDATE       Task
			SET                TaskStatusCode = 3
			FROM            Task.tbTask AS Task INNER JOIN
									 invoiced_quantity ON Task.TaskCode = invoiced_quantity.TaskCode AND Task.Quantity <= invoiced_quantity.InvoiceQuantity INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
			WHERE        (InvoiceTask.InvoiceNumber = @InvoiceNumber) AND (Task.TaskStatusCode < 3);
			
			COMMIT TRANSACTION
		END
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

DROP VIEW IF EXISTS App.vwTaxRates;
DROP VIEW IF EXISTS Task.vwInvoiceValue;
DROP VIEW IF EXISTS Task.vwInvoicedQuantity;
go
ALTER VIEW Invoice.vwSummary
AS
	WITH tasks AS
	(
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
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), items AS
	(
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
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), invoice_entries AS
	(
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         items
		UNION
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         tasks
	), invoice_totals AS
	(
		SELECT     invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
							  SUM(invoice_entries.InvoiceValue) AS TotalInvoiceValue, SUM(invoice_entries.TaxValue) AS TotalTaxValue
		FROM         invoice_entries INNER JOIN
							  Invoice.tbType ON invoice_entries.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		GROUP BY invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType
	), invoice_margin AS
	(
		SELECT     StartOn, 4 AS InvoiceTypeCode, (SELECT CAST([Message] AS NVARCHAR(10)) FROM App.tbText WHERE TextId = 3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
							  AS TotalTaxValue
		FROM         invoice_totals
		GROUP BY StartOn
	)
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
	FROM         invoice_totals
	UNION
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  TotalInvoiceValue, TotalTaxValue
	FROM         invoice_margin;
go
DROP VIEW IF EXISTS Invoice.vwSummaryMargin;
DROP VIEW IF EXISTS Invoice.vwSummaryTotals;
DROP VIEW IF EXISTS Invoice.vwSummaryBase;
DROP VIEW IF EXISTS Invoice.vwSummaryItems;
DROP VIEW IF EXISTS Invoice.vwSummaryTasks;
go
ALTER VIEW App.vwGraphBankBalance
AS
SELECT        Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM') AS PeriodOn, SUM(Cash.vwAccountPeriodClosingBalance.ClosingBalance) AS SumOfClosingBalance
FROM            Cash.vwAccountPeriodClosingBalance INNER JOIN
                         Cash.tbCode ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbCode.CashCode
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, CURRENT_TIMESTAMP))
GROUP BY Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM');
GO

ALTER VIEW Cash.vwAccountStatementListing
AS
	SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
							 App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatement.StartOn, Cash.vwAccountStatement.EntryNumber, Cash.vwAccountStatement.PaymentCode, Cash.vwAccountStatement.PaidOn, 
							 Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, Cash.vwAccountStatement.PaidOutValue, 
							 Cash.vwAccountStatement.PaidBalance, Cash.vwAccountStatement.TaxInValue, Cash.vwAccountStatement.TaxOutValue, Cash.vwAccountStatement.CashCode, 
							 Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, Cash.vwAccountStatement.AccountCode, 
							 Cash.vwAccountStatement.TaxCode
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 Cash.vwAccountStatement INNER JOIN
							 Org.tbAccount ON Cash.vwAccountStatement.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatement.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO
ALTER VIEW Cash.vwAccountPeriodClosingBalance
AS
	WITH last_entries AS
	(
		SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
		FROM         Cash.vwAccountStatement
		GROUP BY CashAccountCode, StartOn
		HAVING      (NOT (StartOn IS NULL))
	)
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn, SUM(Cash.vwAccountStatement.PaidBalance) AS ClosingBalance
	FROM            last_entries INNER JOIN
							 Cash.vwAccountStatement ON last_entries.CashAccountCode = Cash.vwAccountStatement.CashAccountCode AND 
							 last_entries.StartOn = Cash.vwAccountStatement.StartOn AND 
							 last_entries.LastEntry = Cash.vwAccountStatement.EntryNumber INNER JOIN
							 Org.tbAccount ON last_entries.CashAccountCode = Org.tbAccount.CashAccountCode
	GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn
GO
ALTER VIEW Cash.vwAccountStatement
  AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, payment.CashCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Org.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)		
		UNION
		SELECT        Org.tbAccount.CashAccountCode, Org.tbPayment.CashCode, 0 AS EntryNumber, 
			(SELECT CAST(Message AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, DATEADD(HOUR, - 1, MIN(Org.tbPayment.PaidOn)) AS PaidOn, Org.tbAccount.OpeningBalance AS PaidBalance
		FROM            Org.tbAccount INNER JOIN
								 Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbAccount.AccountClosed = 0)
		GROUP BY Org.tbAccount.CashAccountCode, Org.tbPayment.CashCode, Org.tbAccount.OpeningBalance
	), running_balance AS
	(
		SELECT CashAccountCode, CashCode, EntryNumber, PaymentCode, PaidOn, 
			SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
		FROM entries
	), payments AS
	(
		SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
							  Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
							  Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, payments.PaidInValue, 
							payments.PaidOutValue, running_balance.PaidBalance, payments.TaxInValue, 
							payments.TaxOutValue, payments.CashCode, 
							payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode;	
go
DROP VIEW IF EXISTS Cash.vwAccountStatementBase;
go

ALTER VIEW Invoice.vwTaxSummary
AS
	WITH base AS
	(
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbItem
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
		UNION
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbTask
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
	)
	SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, 
	 CASE WHEN SUM(InvoiceValueTotal) <> 0 THEN SUM(TaxValueTotal) / SUM(InvoiceValueTotal) ELSE 0 END AS TaxRate
	FROM            base
	GROUP BY InvoiceNumber, TaxCode;
go
DROP VIEW IF EXISTS Invoice.vwTaxBase;