CREATE OR ALTER VIEW App.vwCorpTaxCashCodes
AS
	WITH category_relations AS
	(
		SELECT        Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode
		FROM            Cash.tbCategoryTotal INNER JOIN
								 Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
								 Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	), cashcode_candidates AS
	(
		SELECT     ChildCode, CashCode
		FROM category_relations
		WHERE     ( CategoryTypeCode = 1) AND ( ParentCode = (SELECT NetProfitCode FROM App.tbOptions))

		UNION ALL

		SELECT     category_relations.ChildCode, category_relations.CashCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CashCode FROM cashcode_candidates
		UNION
		SELECT CashCode FROM category_relations WHERE ParentCode = (SELECT NetProfitCode FROM App.tbOptions)
	)
	SELECT CashCode FROM cashcode_selected WHERE NOT CashCode IS NULL;
go

CREATE OR ALTER VIEW Cash.vwTaxCorpTotalsByPeriod
AS
	WITH tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM tasks GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM items GROUP BY StartOn
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

CREATE OR ALTER VIEW Cash.vwTaxCorpTotals
AS
	SELECT     TOP (100) PERCENT netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
                      App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
                      App.tbYearPeriod.TaxAdjustment, SUM(netprofit_totals.NetProfit) AS NetProfit, SUM(netprofit_totals.CorporationTax) AS CorporationTax
	FROM       Cash.vwTaxCorpTotalsByPeriod  netprofit_totals INNER JOIN
						  App.tbYearPeriod ON netprofit_totals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
						  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
						  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
	WHERE     (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
	GROUP BY App.tbYear.Description, App.tbMonth.MonthName, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn), 
						  App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment;


go
CREATE OR ALTER VIEW Cash.vwTaxCorpStatement
AS
	WITH tax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
		FROM Cash.vwTaxCorpTotalsByPeriod totals
	), tax_entries AS
	(
		SELECT StartOn, SUM(CorporationTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT     Org.tbPayment.PaidOn AS StartOn, 0 As TaxDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS TaxPaid
		FROM         Org.tbPayment INNER JOIN
							  Cash.tbTaxType tt ON Org.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = 0)

	), tax_statement AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	)
	SELECT StartOn, TaxDue, TaxPaid, Balance FROM tax_statement 
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
go



CREATE OR ALTER VIEW [Cash].[vwSummaryBase]
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) 
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

DROP VIEW IF EXISTS Cash.vwCorpTaxInvoice
DROP VIEW IF EXISTS Cash.vwCorpTaxInvoiceBase
DROP VIEW IF EXISTS Cash.vwCorpTaxInvoiceValue
DROP VIEW IF EXISTS Cash.vwCorpTaxInvoiceTasks
DROP VIEW IF EXISTS Cash.vwCorpTaxInvoiceItems
DROP FUNCTION IF EXISTS [Cash].[fnCategoryCashCodes]
DROP FUNCTION IF EXISTS [Cash].[fnCorpTaxCashCodes]
DROP FUNCTION IF EXISTS Cash.fnTaxCorpTotals
DROP VIEW IF EXISTS App.vwCorpTaxCashCode



