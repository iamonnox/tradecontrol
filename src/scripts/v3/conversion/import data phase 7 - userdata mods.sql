/*********************************************************
Trade Control
Import Data from the Version 2 Schema
Release: 3.02.1

Date: 7/5/2018
Author: IaM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

*********************************************************/

IF NOT EXISTS( SELECT * FROM misTradeControl.App.tbYear WHERE YearNumber = 2018)
	INSERT INTO misTradeControl.App.tbYear
							 (YearNumber, StartMonth, CashStatusCode, Description)
	VALUES        (2018, 8, 0, N'2018-19');
go

EXEC misTradeControl.Cash.proc_GeneratePeriods;

UPDATE misTradeControl.App.tbYearPeriod
SET CorporationTaxRate = 0.2
WHERE CorporationTaxRate = 0;

UPDATE misTradeControl.Invoice.tbItem SET InvoiceValue = ROUND(InvoiceValue, 2), PaidValue = ROUND(PaidValue, 2), TaxValue = ROUND(TaxValue, 2), PaidTaxValue = ROUND(PaidTaxValue, 2);
UPDATE misTradeControl.Invoice.tbTask SET InvoiceValue = ROUND(InvoiceValue, 2), PaidValue = ROUND(PaidValue, 2), TaxValue = ROUND(TaxValue, 2), PaidTaxValue = ROUND(PaidTaxValue, 2);

UPDATE misTradeControl.App.tbTaxCode
SET TaxRate = ROUND(ROUND(TaxRate, 4), 3)
GO

