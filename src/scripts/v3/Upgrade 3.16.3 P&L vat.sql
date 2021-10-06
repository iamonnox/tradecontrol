ALTER VIEW [App].[vwPeriods]
AS
	SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYear.CashStatusCode < 3) --AND (App.tbYearPeriod.StartOn < DATEADD(d, 1, CURRENT_TIMESTAMP))
go
CREATE OR ALTER VIEW Cash.vwFlowVatPeriodTotals
AS
	SELECT     active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            App.vwPeriods AS active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatSummary AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn
go
CREATE OR ALTER VIEW Cash.vwFlowVatRecurrence
AS
	SELECT        active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatAdjustment), 0) AS VatAdjustment, ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            App.vwPeriods AS active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn
go
CREATE OR ALTER VIEW Cash.vwFlowTaxType
AS
	SELECT       Cash.tbTaxType.TaxTypeCode, Cash.tbTaxType.TaxType, Cash.tbTaxType.RecurrenceCode, App.tbRecurrence.Recurrence, Cash.tbTaxType.CashCode, Cash.tbCode.CashDescription, Cash.tbTaxType.MonthNumber, App.tbMonth.MonthName, Cash.tbTaxType.AccountCode, 
								Cash.tbTaxType.OffsetDays
	FROM            Cash.tbTaxType INNER JOIN
								App.tbRecurrence ON Cash.tbTaxType.RecurrenceCode = App.tbRecurrence.RecurrenceCode INNER JOIN
								Cash.tbCode ON Cash.tbTaxType.CashCode = Cash.tbCode.CashCode INNER JOIN
								App.tbMonth ON Cash.tbTaxType.MonthNumber = App.tbMonth.MonthNumber
go
