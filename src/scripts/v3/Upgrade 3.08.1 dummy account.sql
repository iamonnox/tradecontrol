UPDATE App.tbOptions SET SQLDataVersion = 3.08
go
ALTER TABLE Org.tbAccount WITH NOCHECK ADD
	DummyAccount BIT NOT NULL CONSTRAINT DF_Org_tbAccount_IsDummyAccount DEFAULT (0);
go
INSERT INTO App.tbText (TextId, [Message], Arguments)
SELECT 3015 AS TextId, 'Dummy accounts should not be assigned a cash code' AS [Message], 0 AS Arguments
go
ALTER TRIGGER [Org].[Org_tbAccount_TriggerUpdate] 
   ON  [Org].[tbAccount]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @Msg NVARCHAR(MAX);

		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
			BEGIN		
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE IF EXISTS (SELECT * FROM inserted i JOIN Cash.tbCode c ON i.CashCode = c.CashCode WHERE DummyAccount <> 0)
			BEGIN
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 3015;
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
ALTER VIEW [Cash].[vwStatement]
AS
	--invoiced taxes
	WITH corp_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)
	), corptax_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn, TaxDue, Balance,
			ROW_NUMBER() OVER (ORDER BY StartOn) AS RowNumber 
		FROM Cash.vwTaxCorpStatement CROSS JOIN corp_taxcode
		WHERE (TaxDue > 0) AND (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2))
	), corptax_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE TaxDue END AS PayOut
		FROM corptax_invoiced_entries
	), vat_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 1)
	), vat_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, VatDue, Balance, 
			ROW_NUMBER() OVER(ORDER BY StartOn) AS RowNumber   
		FROM Cash.vwTaxVatStatement CROSS JOIN vat_taxcode
		WHERE (vatDue > 0) AND (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2))
	), vat_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, TransactOn, 5 AS CashEntryTypeCode, 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE VatDue END AS PayOut
		FROM vat_invoiced_entries
	)
	--uninvoiced taxes
	, task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), corptax_ordered_confirmed AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Task.tbTask.PaymentOn) ORDER BY StartOn DESC) AS StartOn, 
					CASE WHEN Cash.tbCategory.CashModeCode = 0 
						THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) * - 1 
						ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) 
					END AS OrderValue
		FROM            task_invoiced_quantity RIGHT OUTER JOIN
								 App.vwCorpTaxCashCodes AS CashCodes INNER JOIN
								 Cash.tbCategory INNER JOIN
								 Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON CashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Task.tbTask ON CashCodes.CashCode = Task.tbTask.CashCode ON task_invoiced_quantity.TaskCode = Task.tbTask.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0) 
				AND (Task.tbTask.PaymentOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) AS HorizonOn FROM App.tbOptions))
	), corptax_ordered AS
	(
		SELECT        orders.StartOn, SUM(orders.OrderValue * App.tbYearPeriod.CorporationTaxRate) AS TaxDue
		FROM            corptax_ordered_confirmed orders INNER JOIN
								 App.tbYearPeriod ON orders.StartOn = App.tbYearPeriod.StartOn
		GROUP BY orders.StartOn
	), corptax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), corptax_order_totals AS
	(
		SELECT (SELECT PayOn FROM corptax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, TaxDue
		FROM corptax_ordered totals
	), corptax_ordered_entries AS
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM corptax_order_totals
		GROUP BY StartOn
	), corptax_ordered_owing AS
	(	
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
				(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 0 AS PayIn, 
				TaxDue AS PayOut
		FROM corptax_ordered_entries CROSS JOIN corp_taxcode
	), vat_ordered AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.PaymentOn) ORDER BY p.StartOn DESC) AS StartOn,  
				 CASE WHEN Cash.tbCategory.CashModeCode = 0 
					THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) * App.tbTaxCode.TaxRate * - 1 
					ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate 
				END AS TaxDue
		FROM            Task.tbTask INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
								 App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND 
								 (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) 
								 * App.tbTaxCode.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate * - 1 END <> 0) AND 
								 (Task.tbTask.PaymentOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions))
	), vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vat_order_totals AS
	(
		SELECT (SELECT PayOn FROM vat_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, TaxDue
		FROM vat_ordered totals
	), vat_ordered_entries AS	
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM vat_order_totals
		GROUP BY StartOn
	), vat_ordered_owing AS
	(	
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
				(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 0 AS PayIn,
				TaxDue AS PayOut
		FROM vat_ordered_entries CROSS JOIN vat_taxcode
	)
	--unpaid invoices
	, invoices_unpaid_items AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbItem.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbItem.InvoiceNumber AS ReferenceCode, 
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
	), invoices_unpaid_tasks AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbTask.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbTask.InvoiceNumber AS ReferenceCode, 
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
	), tasks_confirmed AS
	(
		SELECT        TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.PaymentOn AS TransactOn, Task.tbTask.PaymentOn, 2 AS CashEntryTypeCode, 
								 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 
								 0)) ELSE 0 END AS PayOut, CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) 
								 * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
		FROM            App.tbTaxCode INNER JOIN
								 Task.tbTask ON App.tbTaxCode.TaxCode = Task.tbTask.TaxCode INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0)
	)
	, statement_unsorted AS
	(
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_ordered_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_ordered_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_items
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_tasks
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM tasks_confirmed
	), statement_sorted AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY TransactOn, CashEntryTypeCode) AS RowNumber,
		 AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_unsorted			
	), opening_balance AS
	(	
		SELECT SUM( Org.tbAccount.CurrentBalance) AS OpeningBalance
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
	), statement_data AS
	(
		SELECT 
			0 AS RowNumber,
			(SELECT TOP (1) AccountCode FROM App.tbOptions) AS AccountCode,
			NULL AS CashCode,
			NULL AS TransactOn,    
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 3013) AS ReferenceCode,	
			1 AS CashEntryTypeCode,
			PayIn = (SELECT OpeningBalance FROM opening_balance),
			0 AS PayOut
		UNION 
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_sorted
	), company_statement AS
	(
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut,
			SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data
	)
	SELECT RowNumber, cs.AccountCode, org.AccountName, cs.CashCode, cc.CashDescription,
		 TransactOn, ReferenceCode, cs.CashEntryTypeCode, et.CashEntryType, PayIn, PayOut, Balance
	FROM company_statement cs 
		JOIN Org.tbOrg org ON cs.AccountCode = org.AccountCode
		JOIN Cash.tbEntryType et ON cs.CashEntryTypeCode = et.CashEntryTypeCode
		LEFT OUTER JOIN Cash.tbCode cc ON cs.CashCode = cc.CashCode;

go
ALTER VIEW [Cash].[vwStatementReserves]
AS
	WITH reserves AS
	(
		SELECT 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1219) AS ReferenceCode,
			(SELECT TOP 1 AccountCode FROM App.tbOptions) AS AccountCode,
			(SELECT MAX( Org.tbPayment.PaidOn)
				FROM         Org.tbAccount INNER JOIN
									  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode LEFT OUTER JOIN
									  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
				WHERE     ( Cash.tbCode.CashCode IS NULL)) AS TransactOn,
			0 AS CashEntryTypeCode,
			0 AS PayIn, 0 AS PayOut,
			(SELECT SUM( Org.tbAccount.CurrentBalance)
				FROM         Org.tbAccount LEFT OUTER JOIN
									  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
				WHERE     ( Org.tbAccount.AccountClosed = 0) AND ( Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount < = 0)) AS Balance
	)
	SELECT     reserves.TransactOn, reserves.CashEntryTypeCode, reserves.ReferenceCode, 
						  reserves.AccountCode, Org.tbOrg.AccountName, Cash.tbEntryType.CashEntryType, reserves.PayOut, 
						  reserves.PayIn, reserves.Balance, NULL AS CashCode, NULL AS CashDescription
	FROM         reserves INNER JOIN
						  Cash.tbEntryType ON reserves.CashEntryTypeCode = Cash.tbEntryType.CashEntryTypeCode INNER JOIN
						  Org.tbOrg ON reserves.AccountCode = Org.tbOrg.AccountCode;
go
ALTER VIEW [Cash].[vwSummaryBase]
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
	), corp_tax AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS CorpTaxBalance FROM Cash.vwTaxCorpStatement ORDER BY StartOn DESC, TaxDue DESC
	), vat AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS VatBalance FROM Cash.vwTaxVatStatement ORDER BY StartOn DESC, VatDue DESC
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
ALTER VIEW [Cash].[vwTaxCorpTotalsByPeriod]
AS
	WITH invoiced_tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), invoiced_items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), candidate_orders AS
	(
		SELECT        task.TaskCode, task.PaymentOn, 
			CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN task.TotalCharge * -1 ELSE task.TotalCharge END AS TotalCharge
		FROM            Task.tbTask AS task INNER JOIN
								 App.vwCorpTaxCashCodes AS cashcodes ON task.CashCode = cashcodes.CashCode INNER JOIN
								 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (task.TaskStatusCode BETWEEN 1 AND 2)
	), partial_invoices AS
	(
		SELECT candidate_orders.TaskCode, 
			CASE WHEN invoice_type.CashModeCode = 0 THEN task_invoice.InvoiceValue * -1 ELSE task_invoice.InvoiceValue END AS InvoiceValue
		FROM candidate_orders JOIN Invoice.tbTask task_invoice ON candidate_orders.TaskCode = task_invoice.TaskCode
			JOIN Invoice.tbInvoice invoice ON task_invoice.InvoiceNumber = invoice.InvoiceNumber
			JOIN Invoice.tbType invoice_type ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
	), orders AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= candidate_orders.PaymentOn) ORDER BY StartOn DESC) AS StartOn, 
			candidate_orders.TotalCharge - ISNULL(partial_invoices.InvoiceValue, 0) AS InvoiceValue
		FROM candidate_orders LEFT JOIN partial_invoices ON candidate_orders.TaskCode = partial_invoices.TaskCode
	)	
	, netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_tasks GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_items GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM orders GROUP BY StartOn
	)
	, netprofit_consolidated AS
	(
		SELECT StartOn, SUM(NetProfit) AS NetProfit FROM netprofits GROUP BY StartOn
	)
	SELECT App.tbYearPeriod.StartOn, netprofit_consolidated.NetProfit, 
							netprofit_consolidated.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
							App.tbYearPeriod.TaxAdjustment
	FROM         netprofit_consolidated INNER JOIN
							App.tbYearPeriod ON netprofit_consolidated.StartOn = App.tbYearPeriod.StartOn;
go


