UPDATE App.tbOptions
SET SQLDataVersion = 3.21
go
ALTER TABLE App.tbOptions WITH NOCHECK ADD
	VatCategoryCode nvarchar(10) NULL
go
CREATE OR ALTER VIEW App.vwCandidateCategoryCodes
AS
	SELECT TOP 100 PERCENT CategoryCode, Category
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 1)
	ORDER BY CategoryCode;
go
DROP VIEW IF EXISTS App.vwCandidateNetProfitCodes;
go
CREATE OR ALTER VIEW App.vwVatTaxCashCodes
AS
	WITH category_relations AS
	(
		SELECT Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode
		FROM  Cash.tbCategoryTotal 
			INNER JOIN Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode 
			LEFT OUTER JOIN Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
		WHERE Cash.tbCategory.CashTypeCode = 0
	), cashcode_candidates AS
	(
		SELECT     ChildCode, CashCode
		FROM category_relations
		WHERE     ( CategoryTypeCode = 1) AND ( ParentCode = (SELECT VatCategoryCode FROM App.tbOptions))

		UNION ALL

		SELECT     category_relations.ChildCode, category_relations.CashCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CashCode FROM cashcode_candidates
		UNION
		SELECT CashCode FROM category_relations WHERE ParentCode = (SELECT VatCategoryCode FROM App.tbOptions)
	)
	SELECT CashCode FROM cashcode_selected WHERE NOT CashCode IS NULL;

go
CREATE OR ALTER VIEW Cash.vwTaxVatSummary
AS

	WITH vat_transactions AS
	(	
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
								 Invoice.tbItem.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
		FROM   App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbItem ON cash_codes.CashCode = Invoice.tbItem.CashCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
		UNION
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
								 Invoice.tbTask.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
		FROM    App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbTask ON cash_codes.CashCode = Invoice.tbTask.CashCode 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
	), vat_detail AS
	(
		SELECT        StartOn, TaxCode, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions
	), vatcode_summary AS
	(
		SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
								AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
		FROM            vat_detail
		GROUP BY StartOn, TaxCode
	)
	SELECT   StartOn, 
		TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat
			, (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vatcode_summary;

go
