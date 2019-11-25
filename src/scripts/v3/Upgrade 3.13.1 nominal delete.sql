UPDATE App.tbOptions
SET SQLDataVersion = 3.13;
go
DELETE FROM Usr.tbMenuEntry
WHERE MenuId = 1 AND (FolderId = 3 OR (FolderId = 1 AND ItemId = 2));

DROP VIEW IF EXISTS Cash.vwCategoryCodesNominal; 
DROP PROCEDURE IF EXISTS Cash.proc_CopyForecastToLiveCashCode;
DROP PROCEDURE IF EXISTS Cash.proc_CopyForecastToLiveCategory;
DROP PROCEDURE IF EXISTS Cash.proc_CopyLiveToForecastCategory;
DROP PROCEDURE IF EXISTS Cash.proc_CopyLiveToForecastCashCode;
DROP PROCEDURE IF EXISTS Cash.proc_FlowInitialise;
DROP PROCEDURE IF EXISTS Cash.proc_CodeValues;

DROP VIEW IF EXISTS Cash.vwNominalEntryData;
DROP VIEW IF EXISTS Cash.vwNominalForecastData;
DROP VIEW IF EXISTS Cash.vwNominalForecastProjection;
DROP VIEW IF EXISTS Cash.vwNominalInvoiceData;
DROP VIEW IF EXISTS Cash.vwCategoriesNominal;
DROP VIEW IF EXISTS Cash.vwAnalysisCodes;
DROP VIEW IF EXISTS Cash.vwCategoriesTrade;
DROP VIEW IF EXISTS Cash.vwCategoriesBank;
DROP VIEW IF EXISTS Cash.vwCategoriesTax;
DROP VIEW IF EXISTS Cash.vwCategoriesTotals;
DROP VIEW IF EXISTS Cash.vwActiveYears;
DROP VIEW IF EXISTS Cash.vwMonthList;
DROP VIEW IF EXISTS Cash.wCategoryCodesExpressions
DROP VIEW IF EXISTS Cash.vwCategoryCodesTotals
DROP VIEW IF EXISTS Cash.vwCategoryCodesTrade
go
CREATE OR ALTER VIEW Cash.vwCategoryExpressions
AS
	SELECT     TOP 100 PERCENT Cash.tbCategory.DisplayOrder, Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryExp.Expression, 
						  Cash.tbCategoryExp.Format
	FROM         Cash.tbCategory INNER JOIN
						  Cash.tbCategoryExp ON Cash.tbCategory.CategoryCode = Cash.tbCategoryExp.CategoryCode
	WHERE     (Cash.tbCategory.CategoryTypeCode = 2)
go
CREATE OR ALTER VIEW Cash.vwCategoryTrade
AS
	SELECT *
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0)
go
CREATE OR ALTER VIEW Cash.vwCategoryBank
AS
	SELECT *
	FROM         Cash.tbCategory
	WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 0)
go
CREATE OR ALTER VIEW Cash.vwCategoryTotals
AS
	SELECT *
	FROM            Cash.tbCategory
	WHERE       (CategoryTypeCode = 1)
go
CREATE OR ALTER VIEW Cash.vwCategoryTax
AS
	SELECT *
	FROM            Cash.tbCategory
	WHERE      (CashTypeCode = 1) AND (CategoryTypeCode = 0)
go
CREATE OR ALTER  VIEW Cash.vwCategoryBudget
AS
	SELECT *
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = 0)
go
CREATE OR ALTER VIEW App.vwActiveYears
   AS
SELECT     TOP 100 PERCENT App.tbYear.YearNumber, App.tbYear.Description, Cash.tbStatus.CashStatus
FROM         App.tbYear INNER JOIN
                      Cash.tbStatus ON App.tbYear.CashStatusCode = Cash.tbStatus.CashStatusCode
WHERE     (App.tbYear.CashStatusCode < 3)
ORDER BY App.tbYear.YearNumber
go
CREATE OR ALTER VIEW App.vwHomeAccount
AS
SELECT        Org.tbOrg.AccountName
FROM            App.tbOptions INNER JOIN
                         Org.tbOrg ON App.tbOptions.AccountCode = Org.tbOrg.AccountCode
go
CREATE OR ALTER VIEW App.vwMonths
AS
	SELECT DISTINCT CAST(App.tbYearPeriod.StartOn AS float) AS StartOn, App.tbMonth.MonthName, App.tbYearPeriod.MonthNumber
	FROM         App.tbYearPeriod INNER JOIN
						  App.fnActivePeriod() AS fnSystemActivePeriod ON App.tbYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
						  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go
CREATE OR ALTER VIEW App.vwActivePeriod
AS
SELECT App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description, App.tbMonth.MonthNumber, App.tbMonth.MonthName, fnActivePeriod.EndOn
FROM            App.tbYear INNER JOIN
                         App.fnActivePeriod() AS fnActivePeriod INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON fnActivePeriod.StartOn = App.tbYearPeriod.StartOn AND fnActivePeriod.YearNumber = App.tbYearPeriod.YearNumber ON 
                         App.tbYear.YearNumber = App.tbYearPeriod.YearNumber
go

CREATE OR ALTER PROCEDURE Cash.proc_FlowInitialise
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION

		EXEC Cash.proc_GeneratePeriods

		UPDATE       Cash.tbPeriod
		SET         InvoiceValue = 0, InvoiceTax = 0
		FROM            Cash.tbPeriod INNER JOIN
								 Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode;

		--Update trade values	
		WITH invoice_summary AS
		(
			SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
			FROM            Invoice.vwRegisterDetail INNER JOIN
									 Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
		)
		UPDATE Cash.tbPeriod
		SET InvoiceValue = invoice_summary.InvoiceValue, 
			InvoiceTax = invoice_summary.TaxValue
		FROM    Cash.tbPeriod INNER JOIN
				invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;

		UPDATE Cash.tbPeriod
		SET 
			InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
		FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
							  Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
							  Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn;


		WITH order_invoice_value AS
		(
			SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
			FROM            Invoice.tbTask
			GROUP BY TaskCode	
		), tasks AS
		(
			SELECT        task.CashCode,
										 (SELECT        TOP (1) StartOn
										   FROM            App.tbYearPeriod
										   WHERE        (StartOn <= task.ActionOn)
										   ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue, 
											ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax, ISNULL(tax.TaxRate, 0) AS TaxRate
			FROM            Task.tbTask AS task INNER JOIN
									 Cash.tbCode AS cash ON task.CashCode = cash.CashCode LEFT OUTER JOIN
									 order_invoice_value ON task.TaskCode = order_invoice_value.TaskCode LEFT OUTER JOIN
									 App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
			WHERE        (task.TaskStatusCode = 1) OR
									 (task.TaskStatusCode = 2)
		), order_summary AS
		(
			SELECT CashCode, StartOn, 
				SUM(TotalCharge - InvoiceValue) AS InvoiceValue,
				SUM((TotalCharge * TaxRate)-InvoiceTax) AS InvoiceTax
			FROM tasks
			GROUP BY CashCode, StartOn
		)
		UPDATE Cash.tbPeriod
		SET
			InvoiceValue = Cash.tbPeriod.InvoiceValue + order_summary.InvoiceValue,
			InvoiceTax = Cash.tbPeriod.InvoiceTax + order_summary.InvoiceTax
		FROM Cash.tbPeriod INNER JOIN
			order_summary ON Cash.tbPeriod.CashCode = order_summary.CashCode
				AND Cash.tbPeriod.StartOn = order_summary.StartOn;	
	               	
	            
		COMMIT TRANSACTION	 
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
DROP PROCEDURE IF EXISTS Cash.proc_CodeValues;
go
CREATE OR ALTER PROCEDURE Cash.proc_FlowCashCodeValues	(@CashCode nvarchar(50), @YearNumber smallint)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		WITH polar_data AS
		(
			SELECT        Cash.tbPeriod.CashCode, Cash.tbCategory.CashTypeCode, Cash.tbPeriod.StartOn, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, 
									 Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
			FROM            Cash.tbPeriod INNER JOIN
									 Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
									 App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
									 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        (App.tbYear.CashStatusCode < 3)
		), flow_data AS
		(
			SELECT        App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, polar_data.CashCode, polar_data.InvoiceValue, 
									 polar_data.InvoiceTax, polar_data.ForecastValue, polar_data.ForecastTax
			FROM            App.tbYearPeriod INNER JOIN
									 polar_data ON App.tbYearPeriod.StartOn = polar_data.StartOn
		)
		SELECT        flow_data.StartOn, flow_data.InvoiceValue, flow_data.InvoiceTax, flow_data.ForecastValue, flow_data.ForecastTax
		FROM            App.tbYearPeriod INNER JOIN
									flow_data ON App.tbYearPeriod.StartOn = flow_data.StartOn
		WHERE        ( App.tbYearPeriod.YearNumber = @YearNumber) AND (flow_data.CashCode = @CashCode)
		ORDER BY flow_data.StartOn;
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
DROP VIEW IF EXISTS Cash.vwFlowData;
DROP VIEW IF EXISTS Cash.vwPolarData;
go
DROP PROCEDURE IF EXISTS Cash.proc_CategoryCashCodes;
go
CREATE OR ALTER PROCEDURE Cash.proc_FlowCategoryCashCodes
	(
	@CategoryCode nvarchar(10)
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		SELECT     CashCode, CashDescription
		FROM         Cash.tbCode
		WHERE     (CategoryCode = @CategoryCode)
		ORDER BY CashDescription		 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
 go
 DROP PROCEDURE IF EXISTS Cash.proc_CategoryTotals;
 go
 CREATE OR ALTER PROCEDURE Cash.proc_FlowCategoryTotalsByType
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 1
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category, Cash.tbType.CashType, Cash.tbCategory.CategoryCode
		FROM         Cash.tbCategory INNER JOIN
							  Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
		WHERE     ( Cash.tbCategory.CashTypeCode = @CashTypeCode) AND ( Cash.tbCategory.CategoryTypeCode = @CategoryTypeCode)
		ORDER BY Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
go
DROP PROCEDURE IF EXISTS Cash.proc_CategoryCodeFromName
go
CREATE OR ALTER PROCEDURE Cash.proc_FlowCategoryCodeFromName
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT CategoryCode
					FROM         Cash.tbCategory
					WHERE     (Category = @Category))
			SELECT @CategoryCode = CategoryCode
			FROM         Cash.tbCategory
			WHERE     (Category = @Category)
		ELSE
			SET @CategoryCode = 0 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
go
UPDATE Cash.tbCategory
SET CashTypeCode = 2
WHERE CashTypeCode = 3;

UPDATE Cash.tbType
SET CashType = 'DELETING'
WHERE CashTypeCode = 3;

UPDATE Cash.tbType
SET CashType = 'BANK'
WHERE CashTypeCode = 2;
go

ALTER VIEW [Cash].[vwCategoryTotalCandidates]
AS
SELECT        Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
FROM            Cash.tbCategory INNER JOIN
                         Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
                         Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Cash.tbCategory.CashTypeCode < 2);
go
ALTER VIEW Cash.vwStatement
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
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 5 AS CashEntryTypeCode, 
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
	--interbank transfers
	, current_account AS
	(
		SELECT        Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Cash.tbCategory.CashTypeCode = 2)
	), accruals AS
	(
		SELECT        Org.tbPayment.AccountCode, Org.tbPayment.CashCode, Org.tbPayment.PaidOn AS TransactOn, Org.tbPayment.PaymentCode AS ReferenceCode, 
			6 AS CashEntryTypeCode, Org.tbPayment.PaidInValue AS PayIn, Org.tbPayment.PaidOutValue AS PayOut
		FROM            current_account INNER JOIN
								 Org.tbPayment ON current_account.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbPayment.PaymentStatusCode = 2)
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
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM accruals
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
ALTER VIEW Cash.vwBankCashCodes
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 2);
go
ALTER VIEW Activity.vwCandidateCashCodes
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode < 2) 
ORDER BY Cash.tbCode.CashCode;
go
ALTER VIEW [Cash].[vwCategoryBank]
AS
	SELECT *
	FROM         Cash.tbCategory
	WHERE     (CashTypeCode = 2) AND (CategoryTypeCode = 0)
go
ALTER VIEW Cash.vwCashFlowTypes
AS
SELECT        CashTypeCode, CashType
FROM            Cash.tbType
WHERE        (CashTypeCode < 2)
go
ALTER TABLE [Cash].[tbCategory] DROP CONSTRAINT DF_Cash_tbCategory_CashTypeCode;
ALTER TABLE [Cash].[tbCategory] ADD CONSTRAINT DF_Cash_tbCategory_CashTypeCode  DEFAULT (0) FOR CashTypeCode;
go
ALTER PROCEDURE [Cash].[proc_CurrentAccount](@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCategory.CashTypeCode = 2);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
DELETE FROM Cash.tbType
WHERE CashTypeCode = 3;
go





