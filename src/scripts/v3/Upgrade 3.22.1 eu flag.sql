UPDATE App.tbOptions
SET SQLDataVersion = 3.22
go
ALTER TABLE Org.tbOrg WITH NOCHECK ADD
	EUJurisdiction bit NOT NULL CONSTRAINT Org_tbOrg_EUJurisdiction DEFAULT (0)
go
UPDATE Org.tbOrg
SET EUJurisdiction = ForeignJurisdiction
go
ALTER TABLE Org.tbOrg DROP
	CONSTRAINT DF_Org_tb_ForeignJurisdiction,
	COLUMN ForeignJurisdiction
go
CREATE OR ALTER VIEW Cash.vwTaxVatAccruals
AS
	WITH task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), task_transactions AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.ActionOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Task.tbTask.TaskCode, Task.tbTask.TaxCode,
				Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) AS QuantityRemaining,
				Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) AS TotalValue, 
				Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate AS TaxValue,
				App.tbTaxCode.TaxRate,
				Org.tbOrg.EUJurisdiction,
				Cash.tbCategory.CashModeCode
		FROM    Task.tbTask INNER JOIN
				Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
				App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
				task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (App.tbTaxCode.TaxTypeCode = 1)
			AND (Task.tbTask.ActionOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions))
	), task_dataset AS
	(
		SELECT StartOn, TaskCode, TaxCode, QuantityRemaining, TotalValue, TaxValue, TaxRate,
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 1 THEN TotalValue ELSE 0 END) ELSE 0 END AS HomeSales, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 0 THEN TotalValue ELSE 0 END) ELSE 0 END AS HomePurchases, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 1 THEN TotalValue ELSE 0 END) ELSE 0 END AS ExportSales, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 0 THEN TotalValue ELSE 0 END) ELSE 0 END AS ExportPurchases, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 1 THEN TaxValue ELSE 0 END) ELSE 0 END AS HomeSalesVat, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 0 THEN TaxValue ELSE 0 END) ELSE 0 END AS HomePurchasesVat, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 1 THEN TaxValue ELSE 0 END) ELSE 0 END AS ExportSalesVat, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 0 THEN TaxValue ELSE 0 END)  ELSE 0 END AS ExportPurchasesVat
		FROM task_transactions
	)
	SELECT task_dataset.*,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM task_dataset
		JOIN App.tbYearPeriod AS year_period ON task_dataset.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber;
go
CREATE OR ALTER VIEW Cash.vwTaxVatAuditInvoices
AS
	WITH vat_transactions AS
	(
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue,
								  ROUND((Invoice.tbItem.TaxValue /  Invoice.tbItem.InvoiceValue), 3) As CalcRate,
								 App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode, Cash.tbCode.CashDescription As ItemDescription
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbItem.InvoiceValue <> 0)
		UNION
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, 
								 ROUND(Invoice.tbTask.TaxValue / Invoice.tbTask.InvoiceValue, 3) AS CalcRate, App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode, tbTask_1.TaskTitle As ItemDescription
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Task.tbTask AS tbTask_1 ON Invoice.tbTask.TaskCode = tbTask_1.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbTask.InvoiceValue <> 0)
	)
	, vat_dataset AS
	(
		SELECT  (SELECT PayTo FROM Cash.fnTaxTypeDueDates(1) due_dates WHERE vat_transactions.InvoicedOn >= PayFrom AND vat_transactions.InvoicedOn < PayTo) AS StartOn,
		 vat_transactions.InvoicedOn, InvoiceNumber, invoice_type.InvoiceType, vat_transactions.InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, TaxRate, EUJurisdiction, IdentityCode, ItemDescription,
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions 
			JOIN Invoice.tbType invoice_type ON vat_transactions.InvoiceTypeCode = invoice_type.InvoiceTypeCode
	)
	SELECT CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, vat_dataset.*,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vat_dataset
		JOIN App.tbYearPeriod AS year_period ON vat_dataset.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber;
go
CREATE OR ALTER VIEW Cash.vwTaxVatSummary
AS

	WITH vat_transactions AS
	(	
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
								 Invoice.tbItem.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
		FROM   App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbItem ON cash_codes.CashCode = Invoice.tbItem.CashCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
		UNION
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
								 Invoice.tbTask.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
		FROM    App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbTask ON cash_codes.CashCode = Invoice.tbTask.CashCode 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
	), vat_detail AS
	(
		SELECT        StartOn, TaxCode, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
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
CREATE OR ALTER VIEW Org.vwDatasheet
AS
	With task_count AS
	(
		SELECT        AccountCode, COUNT(TaskCode) AS TaskCount
		FROM            Task.tbTask
		WHERE        (TaskStatusCode = 1)
		GROUP BY AccountCode
	)
	SELECT        o.AccountCode, o.AccountName, ISNULL(task_count.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.FaxNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.ExpectedDays, o.PayDaysFromMonthEnd, o.PayBalance, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, 
							 o.OpeningBalance, o.EUJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn 
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 task_count ON o.AccountCode = task_count.AccountCode
go
CREATE OR ALTER VIEW Org.vwStatusReport
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.FaxNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.ExpectedDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.EUJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
go
